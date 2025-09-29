import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xpertexams/Core/common_colors/color_extension.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'dart:convert';

/// Enhanced video player with completion tracking and backend synchronization
class VideoContentPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final int? videoId;
  final int? courseId;
  final int? trackId; // Add trackId parameter
  final VoidCallback? onVideoCompleted;

  const VideoContentPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videoId,
    this.courseId,
    this.trackId, // Add trackId parameter
    this.onVideoCompleted,
  });

  @override
  State<VideoContentPage> createState() => _VideoContentPageState();
}

class _VideoContentPageState extends State<VideoContentPage> {
  late YoutubePlayerController _controller;
  late String _youtubeVideoId;
  late String _uniqueKey;
  
  // State management
  bool _isCompleted = false;
  bool _isLoading = true;
  bool _hasWatchedSufficiently = false;
  double _watchProgress = 0.0;
  String? _errorMessage;
  
  // User authentication data
  int? _userId;
  String? _authToken;
  bool _isAuthenticated = false;

  // Constants
  static const double _autoCompleteThreshold = 0.9;
  static const double _sufficientWatchThreshold = 0.8;
  static const String _baseUrl = "http://10.0.2.2:3000"; // Consider making this configurable

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// Initialize video player and load data
  Future<void> _initializeVideo() async {
    try {
      _youtubeVideoId = _extractYouTubeVideoId();
      await _loadUserData();
      _generateUniqueKey();

      if (_youtubeVideoId.isNotEmpty) {
        _initializeYouTubePlayer();
        await _loadCompletionStatus();
        _controller.addListener(_videoProgressListener);
      } else {
        _setErrorState("Invalid YouTube URL");
      }
    } catch (e) {
      _setErrorState("Failed to initialize video: ${e.toString()}");
    } finally {
      _setLoadingState(false);
    }
  }

  /// Extract YouTube video ID from URL
  String _extractYouTubeVideoId() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    return videoId ?? "";
  }

  /// Initialize YouTube player controller
  void _initializeYouTubePlayer() {
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
  }

  /// Generate unique key for local storage
  void _generateUniqueKey() {
    // CRITICAL: Must match exactly with Video model key generation
    // Include trackId to prevent cross-track contamination
    final trackIdentifier = widget.trackId ?? 0;
    final courseIdentifier = widget.courseId ?? 0;
    final videoIdentifier = widget.videoId ?? 0;
    final titleHash = widget.title.hashCode;
    
    _uniqueKey = "completed_track_${trackIdentifier}_course_${courseIdentifier}_video_${videoIdentifier}_${titleHash}";
  }

  /// Load user authentication data
  Future<void> _loadUserData() async {
    try {
      // Try SignInController first
      if (await _loadFromSignInController()) {
        _isAuthenticated = true;
        return;
      }

      // Fallback to SharedPreferences
      await _loadFromSharedPreferences();
      _isAuthenticated = _userId != null && _authToken != null;
      
      _logUserData();
    } catch (e) {
      debugPrint("Error loading user data: $e");
      _isAuthenticated = false;
    }
  }

  /// Load user data from SignInController
  Future<bool> _loadFromSignInController() async {
    try {
      final signInController = Get.find<SignInController>();
      if (signInController.isAuthenticated) {
        final userData = signInController.user.value;
        _userId = userData?.id;
        _authToken = await signInController.getAuthToken();
        return _userId != null && _authToken != null;
      }
    } catch (e) {
      debugPrint("SignInController not available: $e");
    }
    return false;
  }

  /// Load user data from SharedPreferences
  Future<void> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load auth token
    _authToken = prefs.getString('auth_token');
    
    // Try to load user data from JSON
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString);
        _userId = _parseUserId(userData['id']);
      } catch (e) {
        debugPrint("Error parsing user data: $e");
      }
    }
    
    // Fallback to direct user ID
    _userId ??= _parseUserId(prefs.getString('user_id'));
  }

  /// Safely parse user ID
  int? _parseUserId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  /// Log user data for debugging
  void _logUserData() {
    debugPrint("User data loaded - ID: $_userId, HasToken: ${_authToken != null}, Authenticated: $_isAuthenticated");
  }

  /// Listen to video progress changes
  void _videoProgressListener() {
    if (!_controller.value.isReady || !mounted) return;

    final position = _controller.value.position;
    final duration = _controller.metadata.duration;

    if (duration.inSeconds > 0 && position.inSeconds > 0) {
      final watchedPercentage = position.inSeconds / duration.inSeconds;
      
      setState(() {
        _watchProgress = watchedPercentage;
        _hasWatchedSufficiently = watchedPercentage >= _sufficientWatchThreshold;
      });

      // Auto complete when threshold reached
      if (watchedPercentage >= _autoCompleteThreshold && !_isCompleted) {
        _handleVideoCompletion(autoCompleted: true);
      }
    }
  }

  /// Load completion status from all available sources
  Future<void> _loadCompletionStatus() async {
    try {
      // Load from local storage first
      final localStatus = await _loadLocalCompletionStatus();
      setState(() => _isCompleted = localStatus);

      // Check backend if authenticated
      if (_isAuthenticated && _hasRequiredBackendData()) {
        try {
          final backendStatus = await _loadBackendCompletionStatus();
          if (backendStatus != localStatus) {
            setState(() => _isCompleted = backendStatus);
            await _saveLocalCompletionStatus(backendStatus);
          }
        } catch (e) {
          debugPrint("Backend check failed, using local status: $e");
        }
      }
    } catch (e) {
      debugPrint("Error loading completion status: $e");
      setState(() => _isCompleted = false);
    }
  }

  /// Load completion status from local storage
  Future<bool> _loadLocalCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("completed_$_uniqueKey") ?? false;
  }

  /// Load completion status from backend
  Future<bool> _loadBackendCompletionStatus() async {
    final response = await Dio().get(
      "$_baseUrl/completed-videos/$_userId",
      options: Options(
        headers: {"Authorization": "Bearer $_authToken"},
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final completedVideos = List<Map<String, dynamic>>.from(
        response.data["completedVideos"] ?? []
      );

      return completedVideos.any(
        (v) => v["courseId"] == widget.courseId && v["videoId"] == widget.videoId,
      );
    }
    
    throw Exception("Invalid backend response");
  }

  /// Save completion status locally
  Future<void> _saveLocalCompletionStatus(bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("completed_$_uniqueKey", completed);
      debugPrint("Completion saved locally: $completed");
    } catch (e) {
      debugPrint("Error saving local completion: $e");
    }
  }

  /// Send completion status to backend
  Future<void> _syncCompletionWithBackend() async {
    if (!_hasRequiredBackendData()) {
      _logMissingBackendData();
      return;
    }

    try {
      final response = await Dio().post(
        "$_baseUrl/complete-video",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_authToken",
          },
        ),
        data: {
          "userId": _userId,
          "courseId": widget.courseId,
          "videoId": widget.videoId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint("Completion synced with backend: ${response.data['message']}");
      } else {
        debugPrint("Backend sync failed: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error syncing with backend: $e");
    }
  }

  /// Handle video completion
  Future<void> _handleVideoCompletion({bool autoCompleted = false}) async {
    if (_isCompleted) return;

    setState(() => _isCompleted = true);

    // Save locally first (always works)
    await _saveLocalCompletionStatus(true);
    
    // Try to sync with backend
    if (_isAuthenticated) {
      await _syncCompletionWithBackend();
    }

    // Notify callback if provided
    widget.onVideoCompleted?.call();

    // Show completion message
    _showCompletionSnackBar(autoCompleted);

    // Navigate back after delay
    await _delayedNavigation(autoCompleted);
  }

  /// Show completion confirmation dialog
  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: _buildDialogTitle(),
        content: _buildDialogContent(),
        actions: _buildDialogActions(),
      ),
    );
  }

  /// Build dialog title
  Widget _buildDialogTitle() {
    return  Row(
      children: [
        Icon(Icons.check_circle, color: TColor.primary , size: 28),
        const SizedBox(width: 8),
        const Text('Mark as Completed?'),
      ],
    );
  }

  /// Build dialog content
  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Are you sure you want to mark this video as completed?'),
        if (_watchProgress > 0) _buildProgressInfo(),
        if (!_isAuthenticated) _buildOfflineWarning(),
      ],
    );
  }

  /// Build progress information widget
  Widget _buildProgressInfo() {
    return Column(
      children: [
        const SizedBox(height: 12),
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
                  Icon(Icons.timer, size: 16, color: TColor.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Watch Progress: ${(_watchProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: TColor.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _watchProgress,
                backgroundColor: Colors.green[100],
                valueColor: AlwaysStoppedAnimation<Color>(TColor.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build offline warning widget
  Widget _buildOfflineWarning() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Progress will be saved locally only',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build dialog action buttons
  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
          _handleVideoCompletion(autoCompleted: false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.button,
          foregroundColor: TColor.textButton,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Mark Completed'),
      ),
    ];
  }

  /// Show completion snack bar
  void _showCompletionSnackBar(bool autoCompleted) {
    Get.snackbar(
      autoCompleted ? 'Auto Completed!' : 'Completed!',
      autoCompleted
          ? "Video automatically marked as completed!"
          : "You have marked this video as completed!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColor.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Navigate back with delay
  Future<void> _delayedNavigation(bool autoCompleted) async {
    await Future.delayed(Duration(milliseconds: autoCompleted ? 2000 : 500));
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // Utility methods

  bool _hasRequiredBackendData() =>
      _userId != null && 
      _authToken != null && 
      widget.courseId != null && 
      widget.videoId != null;

  void _logMissingBackendData() {
    debugPrint("Missing required data for backend sync:");
    debugPrint("   userId: $_userId");
    debugPrint("   authToken: ${_authToken != null ? 'present' : 'missing'}");
    debugPrint("   courseId: ${widget.courseId}");
    debugPrint("   videoId: ${widget.videoId}");
  }

  void _setLoadingState(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (_youtubeVideoId.isNotEmpty) {
      _controller.removeListener(_videoProgressListener);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScaffold();
    }

    if (_errorMessage != null) {
      return _buildErrorScaffold();
    }

    return _buildMainScaffold();
  }

  /// Build loading scaffold
  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColor.primary),
            const SizedBox(height: 16),
            const Text("Loading video..."),
          ],
        ),
      ),
    );
  }

  /// Build error scaffold
  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Unable to load the video. Please check your connection.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main scaffold with video player
  Widget _buildMainScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
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
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildVideoContent(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.title),
      backgroundColor: Colors.green[400],
      foregroundColor: Colors.white,
      actions: [
        if (_isCompleted)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.verified, color: Colors.white),
          ),
      ],
    );
  }

  /// Build video content area
  Widget _buildVideoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        if (_watchProgress > 0) _buildWatchProgressCard(),
        
        _buildCompletionSection(),
        
        if (!_isCompleted) _buildAutoCompletionTip(),
      ],
    );
  }

  /// Build watch progress card
  Widget _buildWatchProgressCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Watch Progress: ${(_watchProgress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _watchProgress,
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Build completion section
  Widget _buildCompletionSection() {
    if (!_isCompleted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showCompletionDialog,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("Mark as Completed"),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColor.completedone,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "This video is already completed",
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build auto-completion tip
  Widget _buildAutoCompletionTip() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: The video will automatically complete when you watch 90% of it!',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}