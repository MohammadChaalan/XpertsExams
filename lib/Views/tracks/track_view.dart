import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/CourseModel.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Models/VideoModel.dart';
import 'package:xpertexams/Views/tracks/video_player_view.dart';

/// Enhanced Track Courses Page with modern design and video completion tracking
class TrackCoursesView extends StatefulWidget {
  final Track? track;

  const TrackCoursesView({super.key, this.track});

  @override
  State<TrackCoursesView> createState() => _TrackCoursesViewState();
}

class _TrackCoursesViewState extends State<TrackCoursesView>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _authToken;
  int? _userId;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeView();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// =========================
  /// User Credentials & Data Management
  /// =========================
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_id");
    await prefs.remove("auth_token");

    // Clear all user-specific video completion keys
    final allKeys = prefs.getKeys();
    final userKeys = allKeys.where((k) => k.startsWith("user_")).toList();
    for (final key in userKeys) {
      await prefs.remove(key);
    }
    debugPrint("Cleared ${userKeys.length} user-specific keys");
  }

  /// =========================
  /// Initialization & Data Loading
  /// =========================
  Future<void> _initializeView() async {
    try {
      await _loadUserCredentials();
      await _loadAllVideoStatuses();
      _animationController.forward();
    } catch (e) {
      _setErrorState("Failed to initialize view: ${e.toString()}");
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _loadUserCredentials() async {
    _authToken = await getAuthToken();
    _userId = await getUserId();
    debugPrint(
        "User credentials - userId=$_userId, hasToken=${_authToken != null}");
  }

  Future<void> _loadAllVideoStatuses() async {
    final courses = widget.track?.courses ?? [];
    for (final course in courses) {
      await _loadCourseVideoStatuses(course);
    }
  }

  Future<void> _loadCourseVideoStatuses(Course course) async {
    try {
      // Load local completion statuses
      await Future.wait(
          course.video.map((v) => v.loadCompletionStatus(userId: _userId)));

      // Sync with backend if authenticated
      if (_isUserAuthenticated()) {
        await _syncWithBackend(course);
      }
    } catch (e) {
      debugPrint("Error loading course video statuses: $e");
    }
  }

  Future<void> _syncWithBackend(Course course) async {
    try {
      final completedVideos = await _fetchCompletedVideosFromBackend();

      for (final video in course.video) {
        final isCompletedOnBackend = completedVideos
            .any((v) => v["courseId"] == course.id && v["videoId"] == video.id);

        if (isCompletedOnBackend && !video.isCompleted) {
          await video.setCompletionStatus(true, userId: _userId);
        }
      }
    } catch (e) {
      debugPrint("Backend sync failed: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCompletedVideosFromBackend() async {
    final response = await DioClient().getInstance().get(
          "/completed-videos/$_userId",
          options: Options(headers: {"Authorization": "Bearer $_authToken"}),
        );

    if (response.statusCode == 200 && response.data["success"] == true) {
      return List<Map<String, dynamic>>.from(
          response.data["completedVideos"] ?? []);
    }
    return [];
  }

  /// =========================
  /// Video Completion Handling
  /// =========================
  Future<void> _markVideoAsCompleted(Video video) async {
    try {
      final result = await video.markAsCompleted(
        syncToBackend: _isUserAuthenticated(),
        userId: _userId,
      );

      if (result.success) {
        await video.refreshCompletionStatus(userId: _userId);
        if (mounted) {
          setState(() {});
          _showSuccessSnack("Video completed successfully!");
        }
      } else {
        _showErrorSnack(
            result.errorMessage ?? "Failed to mark video as completed");
      }
    } catch (e) {
      _showErrorSnack("Error updating completion status");
    }
  }

  /// =========================
  /// Navigation & Video Handling
  /// =========================
  Future<void> _handleVideoTap(Video video, Course course) async {
    if (!video.hasValidUrl) {
      _showErrorSnack("Video URL not available");
      return;
    }

    // Add loading state for better UX
    _showLoadingSnack("Loading video...");

    try {
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => FadeTransition(
            opacity: animation,
            child: VideoContentPage(
              videoUrl: video.url!,
              title: video.title,
              videoId: video.id,
              courseId: course.id,
              trackId: widget.track?.id,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );

      // Refresh all video statuses when returning
      await _loadAllVideoStatuses();
      if (mounted) setState(() {});

      // Handle completion if video was marked as completed
      if (result == true) {
        await _markVideoAsCompleted(video);
      }
    } catch (e) {
      _showErrorSnack("Failed to open video: ${e.toString()}");
    }
  }

  /// =========================
  /// Progress Calculation
  /// =========================
  CourseProgress _calculateCourseProgress(Course course) {
    if (course.video.isEmpty) return CourseProgress.empty();

    final completed = course.video.where((v) => v.isCompleted).length;
    final total = course.video.length;

    return CourseProgress(
      completed: completed,
      total: total,
      ratio: completed / total,
    );
  }

  TrackProgress _calculateTrackProgress() {
    final courses = widget.track?.courses ?? [];
    if (courses.isEmpty) return TrackProgress.empty();

    int totalVideos = 0;
    int completedVideos = 0;

    for (final course in courses) {
      totalVideos += course.video.length;
      completedVideos += course.video.where((v) => v.isCompleted).length;
    }

    return TrackProgress(
      completed: completedVideos,
      total: totalVideos,
      ratio: totalVideos > 0 ? completedVideos / totalVideos : 0.0,
    );
  }

  /// =========================
  /// UI Building Methods
  /// =========================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScaffold();
    if (_errorMessage != null) return _buildErrorScaffold();
    return _buildMainScaffold();
  }

  Widget _buildMainScaffold() {
    final trackProgress = _calculateTrackProgress();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(trackProgress),
          SliverToBoxAdapter(child: _buildTrackProgressCard(trackProgress)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final courses = widget.track?.courses ?? [];
                if (index >= courses.length) return null;

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.1,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    )),
                    child: _buildCourseCard(courses[index]),
                  ),
                );
              },
              childCount: widget.track?.courses.length ?? 0,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(TrackProgress progress) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      foregroundColor: Colors.white,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            widget.track?.name ?? "Track",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildTrackProgressCard(TrackProgress progress) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: progress.isComplete
                  ? [Colors.green[300]!, Colors.green[500]!]
                  : [Colors.blue[300]!, Colors.purple[400]!],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      progress.isComplete ? Icons.verified : Icons.trending_up,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Track Progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${progress.completed}/${progress.total} videos completed",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.ratio,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${progress.percentageString}% Complete",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (progress.isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "COMPLETED",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final progress = _calculateCourseProgress(course);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding : EdgeInsets.all(10),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: progress.isComplete
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [Colors.blue[400]!, Colors.indigo[500]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    progress.isComplete ? Icons.check : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress.ratio,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            course.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (course.description?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  course.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: progress.isComplete
                          ? Colors.green[100]
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${progress.percentageString}% Complete",
                      style: TextStyle(
                        color: progress.isComplete
                            ? Colors.green[700]
                            : Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.video_library, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    "${course.video.length} videos",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: course.video
              .asMap()
              .entries
              .map((entry) => _buildVideoTile(entry.key, entry.value, course))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildVideoTile(int index, Video video, Course course) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: video.isCompleted ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: video.isCompleted ? Colors.green[200]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: video.isCompleted
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.blue[400]!, Colors.indigo[500]!],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            video.isCompleted ? Icons.check_circle : Icons.play_arrow,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: video.isCompleted ? Colors.green[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color:
                      video.isCompleted ? Colors.green[700] : Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                video.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                video.duration,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              if (video.isCompleted) ...[
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "COMPLETED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: video.isCompleted ? Colors.green[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: video.isCompleted ? Colors.green[600] : Colors.blue[600],
          ),
        ),
        onTap: () => _handleVideoTap(video, course),
      ),
    );
  }

 

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[400]!, Colors.green[200]!],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                "Loading your courses...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _initializeView,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                "Try Again",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// Utility Methods
  /// =========================
  bool _isUserAuthenticated() => _userId != null && _authToken != null;

  void _setLoadingState(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLoadingSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Progress tracking data classes
class CourseProgress {
  final int completed;
  final int total;
  final double ratio;

  const CourseProgress({
    required this.completed,
    required this.total,
    required this.ratio,
  });

  factory CourseProgress.empty() {
    return const CourseProgress(completed: 0, total: 0, ratio: 0.0);
  }

  bool get isComplete => ratio >= 1.0;
  String get percentageString => (ratio * 100).toStringAsFixed(0);
}

class TrackProgress {
  final int completed;
  final int total;
  final double ratio;

  const TrackProgress({
    required this.completed,
    required this.total,
    required this.ratio,
  });

  factory TrackProgress.empty() {
    return const TrackProgress(completed: 0, total: 0, ratio: 0.0);
  }

  bool get isComplete => ratio >= 1.0;
  String get percentageString => (ratio * 100).toStringAsFixed(0);
}
