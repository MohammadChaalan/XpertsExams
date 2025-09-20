import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Models/CourseModel.dart';
import 'package:xpertexams/Models/VideoModel.dart';
import 'package:xpertexams/Views/tracks/video_player_view.dart';

class TrackCoursesView extends StatefulWidget {
  final Track? track;

  const TrackCoursesView({super.key, this.track});

  @override
  State<TrackCoursesView> createState() => _TrackCoursesViewState();
}

class _TrackCoursesViewState extends State<TrackCoursesView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideoCompletionStatuses();
  }

  /// Load completion statuses for all videos in all courses
  Future<void> _loadVideoCompletionStatuses() async {
    try {
      for (final course in widget.track!.courses) {
        for (final video in course.video) {
          await video.loadCompletionStatus();
        }
      }
    } catch (e) {
      print("❌ Error loading video completion statuses: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Calculate completion percentage for a course
  double _calculateCourseProgress(Course course) {
    if (course.video.isEmpty) return 0.0;
    
    final completedCount = course.video.where((video) => video.isCompleted).length;
    return (completedCount / course.video.length) * 100;
  }

  /// Calculate overall track progress
  double _calculateTrackProgress() {
    if (widget.track?.courses.isEmpty ?? true) return 0.0;

    int totalVideos = 0;
    int completedVideos = 0;

    for (final course in widget.track!.courses) {
      totalVideos += course.video.length;
      completedVideos += course.video.where((video) => video.isCompleted).length;
    }
 
    return totalVideos > 0 ? (completedVideos / totalVideos) * 100 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[400],
          centerTitle: true,
          title: Text(
            widget.track!.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text("Loading course progress..."),
            ],
          ),
        ),
      );
    }

    final trackProgress = _calculateTrackProgress();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.track!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Overall progress indicator
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[300]!, Colors.green[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  trackProgress == 100 ? Icons.verified : Icons.school,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     const Text(
                        "Track Progress",
                        style:   TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: trackProgress / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${trackProgress.toStringAsFixed(0)}% Complete",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Courses list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.track!.courses.length,
              itemBuilder: (context, index) {
                final Course course = widget.track!.courses[index];
                final courseProgress = _calculateCourseProgress(course);
                final completedVideos = course.video.where((v) => v.isCompleted).length;
                final totalVideos = course.video.length;

                return Card(
                  color: Colors.green[50],
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    initiallyExpanded: false,
                    leading: CircularProgressIndicator(
                      value: courseProgress / 100,
                      backgroundColor: Colors.green[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        courseProgress == 100 ? Colors.green[700]! : Colors.green,
                      ),
                    ),
                    title: Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (course.description != null && course.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              course.description!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          "$completedVideos/$totalVideos videos completed",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: courseProgress == 100 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${courseProgress.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    children: course.video.asMap().entries.map((entry) {
                      final int videoIndex = entry.key;
                      final Video video = entry.value;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: video.isCompleted ? Colors.green[200] : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: video.isCompleted ? Colors.green[300]! : Colors.green[200]!,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: video.isCompleted ? Colors.green[700] : Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              video.isCompleted ? Icons.check : Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                "${videoIndex + 1}. ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  video.title,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.duration,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 16),
                              if (video.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    borderRadius: BorderRadius.circular(8),
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
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                          onTap: () async {
                            if (video.url != null && video.url!.isNotEmpty) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoContentPage(
                                    videoUrl: video.url!,
                                    title: video.title,
                                    videoId: video.id, // Pass the video ID for unique identification
                                  ),
                                ),
                              );
                              
                              if (result == true) {
                                // Mark as completed and save
                                await video.markAsCompleted();
                                
                                print("🔄 Updating UI after video completion: ${video.title}");
                                
                                if (mounted) {
                                  setState(() {
                                    // Trigger rebuild to update progress
                                  });
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("❌ Video URL not available"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}