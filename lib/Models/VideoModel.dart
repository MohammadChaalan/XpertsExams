import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Video {
  final int id;
  final String title;
  final String duration;
  final String? url;
  bool isCompleted;
  String? _videoId; // Cache video ID for SharedPreferences
  String? _uniqueKey; // Unique key for this specific video

  Video({
    required this.id,
    required this.title,
    required this.duration,
    this.url,
    this.isCompleted = false,
  }) {
    // Extract video ID from URL for SharedPreferences key
    if (url != null) {
      _videoId = YoutubePlayer.convertUrlToId(url!);
    }
    // Create unique key using both video ID and internal ID to prevent conflicts
    _uniqueKey = _videoId != null ? "${_videoId}_${id}" : "video_${id}";
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      url: json['url'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'url': url,
        'isCompleted': isCompleted,
      };

  /// Load completion status from SharedPreferences
  Future<void> loadCompletionStatus() async {
    if (_uniqueKey == null || _uniqueKey!.isEmpty) {
      print("⚠️ No unique key for video: $title (ID: $id)");
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool("completed_$_uniqueKey") ?? false;
      isCompleted = completed;
      print("📱 Loaded completion for '$title': $completed (Key: completed_$_uniqueKey)");
    } catch (e) {
      print("❌ Error loading completion status for video $_uniqueKey: $e");
    }
  }

  /// Save completion status to SharedPreferences
  Future<void> saveCompletionStatus() async {
    if (_uniqueKey == null || _uniqueKey!.isEmpty) {
      print("⚠️ No unique key for video: $title (ID: $id)");
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("completed_$_uniqueKey", isCompleted);
      print("💾 Saved completion for '$title': $isCompleted (Key: completed_$_uniqueKey)");
    } catch (e) {
      print("❌ Error saving completion status for video $_uniqueKey: $e");
    }
  }

  /// Mark video as completed and save to SharedPreferences
  Future<void> markAsCompleted() async {
    print("✅ Marking video as completed: '$title' (ID: $id)");
    isCompleted = true;
    await saveCompletionStatus();
  }

  /// Reset video completion status
  Future<void> resetCompletion() async {
    print("🔄 Resetting completion for: '$title' (ID: $id)");
    isCompleted = false;
    await saveCompletionStatus();
  }

  /// Get the YouTube video ID
  String? get videoId => _videoId;
  
  /// Get the unique key used for SharedPreferences
  String? get uniqueKey => _uniqueKey;

  /// Debug method to check current completion status
  Future<bool> debugCheckCompletion() async {
    if (_uniqueKey == null || _uniqueKey!.isEmpty) return false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool("completed_$_uniqueKey") ?? false;
      print("🔍 Debug - Video: '$title', Memory: $isCompleted, Saved: $saved, Key: $_uniqueKey");
      return saved;
    } catch (e) {
      print("❌ Debug check error: $e");
      return false;
    }
  }

  /// Force refresh completion status from SharedPreferences
  Future<void> refreshCompletionStatus() async {
    await loadCompletionStatus();
  }

  @override
  String toString() {
    return 'Video(id: $id, title: $title, isCompleted: $isCompleted, uniqueKey: $_uniqueKey)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}