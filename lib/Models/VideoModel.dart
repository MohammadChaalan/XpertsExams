import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A model class representing a video with completion tracking capabilities
class Video {
  final int id;
  final String title;
  final String duration;
  final String? url;
  final int? courseId;
  final int? trackId; // Add trackId to ensure uniqueness
  
  bool _isCompleted;
  late final String _videoId;
  late final String _uniqueKey;
  
  // Private constructor to enforce proper initialization
  Video._({
    required this.id,
    required this.title,
    required this.duration,
    this.url,
    this.courseId,
    this.trackId, // Add trackId parameter
    bool isCompleted = false,
  }) : _isCompleted = isCompleted {
    _initializeVideoProperties();
  }
  
  /// Public factory constructor
  factory Video({
    required int id,
    required String title,
    required String duration,
    String? url,
    int? courseId,
    int? trackId, // Add trackId parameter
    bool isCompleted = false,
  }) {
    return Video._(
      id: id,
      title: title,
      duration: duration,
      url: url,
      courseId: courseId,
      trackId: trackId, // Pass trackId
      isCompleted: isCompleted,
    );
  }

  /// Factory constructor for creating Video from JSON
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video._(
      id: _parseIntSafely(json['id']),
      title: json['title']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      url: json['url']?.toString(),
      courseId: _parseIntSafely(json['courseId']),
      trackId: _parseIntSafely(json['trackId']), // Add trackId parsing
      isCompleted: json['isCompleted'] == true,
    );
  }

  /// Initialize video-specific properties
  void _initializeVideoProperties() {
    _videoId = _extractVideoId();
    _uniqueKey = _generateUniqueKey();
  }

  /// Extract YouTube video ID from URL or generate fallback
  String _extractVideoId() {
    if (url == null) return "video_$id";
    return YoutubePlayer.convertUrlToId(url!) ?? "video_$id";
  }

  /// Generate unique key for SharedPreferences storage
  String _generateUniqueKey() {
    // CRITICAL: Include trackId to prevent cross-track contamination
    // Your backend has same courseIds across different tracks
    final trackIdentifier = trackId ?? 0;
    final courseIdentifier = courseId ?? 0;
    
    // NOTE: This key does NOT include userId - that must be handled at storage level
    return "completed_track_${trackIdentifier}_course_${courseIdentifier}_video_${id}_${title.hashCode}";
  }

  /// Get user-specific storage key
  String getUserSpecificKey(int userId) {
    return "user_${userId}_${_uniqueKey}";
  }

  /// Safe integer parsing with fallback
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  // Getters
  bool get isCompleted => _isCompleted;
  String get videoId => _videoId;
  String get uniqueKey => _uniqueKey;
  bool get hasValidUrl => url != null && url!.isNotEmpty;

  /// Convert Video object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'url': url,
        'isCompleted': _isCompleted,
        'courseId': courseId,
        'trackId': trackId, // Include trackId in JSON
      };

  /// Load completion status from local storage
  Future<bool> loadCompletionStatus({int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = userId != null ? getUserSpecificKey(userId) : _uniqueKey;
      final storedStatus = prefs.getBool(storageKey);
      
      // DEBUG: Print the key being used
      debugPrint("Loading completion for: ${title}");
      debugPrint("  UserID: ${userId}");
      debugPrint("  CourseID: ${courseId}");
      debugPrint("  VideoID: ${id}");  
      debugPrint("  Storage Key: ${storageKey}");
      debugPrint("  Stored Status: ${storedStatus}");
      
      if (storedStatus != null) {
        _isCompleted = storedStatus;
      }
      
      return _isCompleted;
    } catch (e) {
      _logError("Failed to load completion status", e);
      return _isCompleted;
    }
  }

  /// Save completion status to local storage
  Future<bool> saveCompletionStatus({int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = userId != null ? getUserSpecificKey(userId) : _uniqueKey;
      final success = await prefs.setBool(storageKey, _isCompleted);
      
      if (success) {
        // DEBUG: Print the key being used
        debugPrint("Saving completion for: ${title}");
        debugPrint("  UserID: ${userId}");
        debugPrint("  CourseID: ${courseId}");
        debugPrint("  VideoID: ${id}");  
        debugPrint("  Storage Key: ${storageKey}");
        debugPrint("  Status: ${_isCompleted}");
        _logInfo("Completion status saved", "Video: '$title', Status: $_isCompleted");
      }
      
      return success;
    } catch (e) {
      _logError("Failed to save completion status", e);
      return false;
    }
  }

  /// Mark video as completed with optional backend sync
  Future<VideoCompletionResult> markAsCompleted({bool syncToBackend = false, int? userId}) async {
    _isCompleted = true;
    final localSaveSuccess = await saveCompletionStatus();
    
    if (!localSaveSuccess) {
      return VideoCompletionResult.localError();
    }
    
    if (syncToBackend) {
      // Placeholder for backend sync logic
      _logInfo("Backend sync initiated", "Video: '$title' (ID: $id)");
      // TODO: Implement actual backend sync
      return VideoCompletionResult.success(syncedToBackend: true);
    }
    
    return VideoCompletionResult.success(syncedToBackend: false);
  }

  /// Reset video completion status
  Future<bool> resetCompletion() async {
    _isCompleted = false;
    final success = await saveCompletionStatus();
    
    if (success) {
      _logInfo("Completion reset", "Video: '$title' (ID: $id)");
    }
    
    return success;
  }

  /// Update completion status without saving to storage
  void updateCompletionStatus(bool completed) {
    _isCompleted = completed;
  }

  /// Set completion status and save to storage
  Future<bool> setCompletionStatus(bool completed, {int? userId}) async {
    _isCompleted = completed;
    return await saveCompletionStatus();
  }

  /// Refresh completion status from storage
  Future<bool> refreshCompletionStatus({int? userId}) async {
    return await loadCompletionStatus();
  }

  /// Debug method to check completion status consistency
  Future<CompletionDebugInfo> debugCompletionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStatus = prefs.getBool("completed_$_uniqueKey") ?? false;
      
      return CompletionDebugInfo(
        videoTitle: title,
        memoryStatus: _isCompleted,
        storedStatus: storedStatus,
        uniqueKey: _uniqueKey,
        isConsistent: _isCompleted == storedStatus,
      );
    } catch (e) {
      _logError("Debug check failed", e);
      return CompletionDebugInfo.error(title, _uniqueKey);
    }
  }

  /// Clear stored completion data
  Future<bool> clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove("completed_$_uniqueKey");
    } catch (e) {
      _logError("Failed to clear stored data", e);
      return false;
    }
  }

  // Logging methods
  void _logInfo(String action, String details) {
    print("📱 [$action] $details");
  }

  void _logError(String action, dynamic error) {
    print("❌ [$action] Error: $error");
  }

  @override
  String toString() {
    return 'Video(id: $id, title: "$title", isCompleted: $_isCompleted, courseId: $courseId, uniqueKey: $_uniqueKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Video &&
            other.id == id &&
            other.title == title &&
            other.courseId == courseId);
  }

  @override
  int get hashCode => Object.hash(id, title, courseId);
}

/// Result class for video completion operations
class VideoCompletionResult {
  final bool success;
  final bool syncedToBackend;
  final String? errorMessage;

  const VideoCompletionResult._({
    required this.success,
    required this.syncedToBackend,
    this.errorMessage,
  });

  factory VideoCompletionResult.success({required bool syncedToBackend}) {
    return VideoCompletionResult._(
      success: true,
      syncedToBackend: syncedToBackend,
    );
  }

  factory VideoCompletionResult.localError([String? message]) {
    return VideoCompletionResult._(
      success: false,
      syncedToBackend: false,
      errorMessage: message ?? "Failed to save completion status locally",
    );
  }

  factory VideoCompletionResult.backendError([String? message]) {
    return VideoCompletionResult._(
      success: false,
      syncedToBackend: false,
      errorMessage: message ?? "Failed to sync completion status to backend",
    );
  }
}

/// Debug information for completion status
class CompletionDebugInfo {
  final String videoTitle;
  final bool memoryStatus;
  final bool storedStatus;
  final String uniqueKey;
  final bool isConsistent;
  final String? errorMessage;

  const CompletionDebugInfo({
    required this.videoTitle,
    required this.memoryStatus,
    required this.storedStatus,
    required this.uniqueKey,
    required this.isConsistent,
    this.errorMessage,
  });

  factory CompletionDebugInfo.error(String title, String key) {
    return CompletionDebugInfo(
      videoTitle: title,
      memoryStatus: false,
      storedStatus: false,
      uniqueKey: key,
      isConsistent: false,
      errorMessage: "Debug check failed",
    );
  }

  @override
  String toString() {
    return 'CompletionDebugInfo(video: "$videoTitle", memory: $memoryStatus, stored: $storedStatus, consistent: $isConsistent, key: $uniqueKey)';
  }
}