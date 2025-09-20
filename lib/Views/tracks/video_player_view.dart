import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class VideoContentPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final int? videoId; // Add video ID to make unique identification

  const VideoContentPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videoId,
  });

  @override
  State<VideoContentPage> createState() => _VideoContentPageState();
}

class _VideoContentPageState extends State<VideoContentPage> {
  late YoutubePlayerController _controller;
  late String _youtubeVideoId;
  late String _uniqueKey; // Unique key for this specific video
  bool _isCompleted = false;
  bool _isLoading = true;
  bool _hasWatchedSufficiently = false;
  double _watchProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _youtubeVideoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "";
    
    // Create unique key using both YouTube video ID and our internal video ID
    _uniqueKey = widget.videoId != null 
        ? "${_youtubeVideoId}_${widget.videoId}" 
        : "${_youtubeVideoId}_${widget.title.hashCode}";
    
    print("🔑 Video unique key: $_uniqueKey for '${widget.title}'");
    
    if (_youtubeVideoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: _youtubeVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          forceHD: false,
          startAt: 0,
        ),
      );
      
      // Load completion status
      await _loadCompletion();
      
      // Add listener for video events
      _controller.addListener(_videoListener);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _videoListener() {
    if (_controller.value.isReady && mounted) {
      final position = _controller.value.position;
      final duration = _controller.metadata.duration;
      
      // Calculate watch progress
      if (duration.inSeconds > 0 && position.inSeconds > 0) {
        final watchedPercentage = position.inSeconds / duration.inSeconds;
        setState(() {
          _watchProgress = watchedPercentage;
          _hasWatchedSufficiently = watchedPercentage >= 0.8; // 80% threshold
        });
        
        // Auto-mark as completed when video is 90% watched
        if (watchedPercentage >= 0.9 && !_isCompleted) {
          _onCompleted(autoCompleted: true);
        }
      }
    }
  }

  Future<void> _loadCompletion() async {
    if (_uniqueKey.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool("completed_$_uniqueKey") ?? false;
      
      print("📱 Loading completion for '${widget.title}': $completed (Key: completed_$_uniqueKey)");
      
      if (mounted) {
        setState(() {
          _isCompleted = completed;
        });
      }
    } catch (e) {
      print("❌ Error loading completion status: $e");
    }
  }

  Future<void> _saveCompletion() async {
    if (_uniqueKey.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("completed_$_uniqueKey", true);
      print("💾 Video completion saved for '${widget.title}' (Key: completed_$_uniqueKey)");
    } catch (e) {
      print("❌ Error saving completion: $e");
    }
  }

  void _onCompleted({bool autoCompleted = false}) async {
    if (_isCompleted) return; // Prevent multiple completions
    
    setState(() {
      _isCompleted = true;
    });

    // Save completion status
    await _saveCompletion();

    // Show appropriate snackbar using GetX
    Get.snackbar(
      autoCompleted ? 'Auto Completed!' : 'Completed!',
      autoCompleted 
        ? "🎉 Video automatically marked as completed!"
        : "🎉 You have marked this video as completed!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    // Return completion status to parent after a delay
    if (autoCompleted) {
      await Future.delayed(const Duration(seconds: 2));
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    if (mounted) {
      // Return true to indicate video was completed
      Get.back(result: true);
    }
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Mark as Completed?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to mark this video as completed?'),
            const SizedBox(height: 12),
            if (_watchProgress > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Watch Progress: ${(_watchProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _watchProgress,
                      backgroundColor: Colors.green[100],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _onCompleted(autoCompleted: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_youtubeVideoId.isNotEmpty) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green[400],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text(
                "Loading video...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_youtubeVideoId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green[400],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Invalid YouTube URL",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Unable to load the video. Please check the URL and try again.",
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.verified,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.green,
          progressColors: ProgressBarColors(
            playedColor: Colors.green,
            handleColor: Colors.green[700]!,
            bufferedColor: Colors.green[200]!,
            backgroundColor: Colors.grey[300]!,
          ),
          onReady: () {
            print("🎥 YouTube player is ready for: ${widget.title}");
          },
        ),
        builder: (context, player) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              player,
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Course Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Completion Status Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: _isCompleted
                                  ? [Colors.green[300]!, Colors.green[500]!]
                                  : _hasWatchedSufficiently
                                      ? [Colors.blue[300]!, Colors.blue[500]!]
                                      : [Colors.orange[300]!, Colors.orange[500]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isCompleted ? Colors.green : _hasWatchedSufficiently ? Colors.blue : Colors.orange).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _isCompleted 
                                      ? Icons.check_circle 
                                      : _hasWatchedSufficiently 
                                          ? Icons.thumb_up
                                          : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isCompleted 
                                          ? "Completed ✨" 
                                          : _hasWatchedSufficiently 
                                              ? "Well Watched!"
                                              : "In Progress",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _isCompleted 
                                          ? "Great job! You've completed this video."
                                          : _hasWatchedSufficiently
                                              ? "You've watched most of this video. Ready to mark as complete?"
                                              : "Watch the video or mark as completed when done.",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (_watchProgress > 0 && !_isCompleted) ...[
                                      const SizedBox(height: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Progress: ${(_watchProgress * 100).toInt()}%",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: _watchProgress,
                                            backgroundColor: Colors.white.withOpacity(0.3),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                            minHeight: 3,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Completion Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCompleted ? Colors.grey[400] : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: _isCompleted ? 0 : 6,
                              shadowColor: Colors.green.withOpacity(0.3),
                            ),
                            onPressed: _isCompleted ? null : _showCompletionDialog,
                            icon: Icon(
                              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                              size: 24,
                            ),
                            label: Text(
                              _isCompleted ? "Already Completed" : "Mark as Completed",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),

                      // Progress tip
                      if (!_isCompleted)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Colors.blue[600], size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "💡 Tip: The video will auto-complete when you watch 90% of it!",
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}