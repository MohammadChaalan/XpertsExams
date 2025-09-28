import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
import 'package:xpertexams/Views/test/TestCourseSelection_view.dart';
import 'package:xpertexams/Views/test/test_view.dart';
import 'package:xpertexams/Views/tracks/track_view.dart';

class TracksContentView extends StatefulWidget {
  const TracksContentView({super.key});

  @override
  State<TracksContentView> createState() => _TracksContentViewState();
}

class _TracksContentViewState extends State<TracksContentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Tracks"),
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: GetBuilder<SignInController>(
        init: Get.find<SignInController>(),
        builder: (signInController) {
          final tracks = signInController.getTracks();

          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Learning Tracks Available",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Contact your administrator to get access to learning tracks",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header section with stats
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[300]!, Colors.green[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
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
                            "Your Learning Journey",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${tracks.length} track${tracks.length == 1 ? '' : 's'} available",
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
              ),

              // Tracks list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _buildTrackCard(track, context);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomBarPage(initialIndex: 3,),
    );
  }

  Widget _buildTrackCard(Track track, BuildContext context) {
    // Calculate track statistics
    final totalCourses = track.courses.length;
    final totalVideos = track.courses.fold<int>(
      0,
      (sum, course) => sum + course.video.length,
    );
    final totalExams = track.courses.fold<int>(
      0,
      (sum, course) => sum + (course.exams?.length ?? 0),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onTrackSelected(track),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.green[50]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTrackIcon(track.name),
                        color: Colors.green[700],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap to explore courses",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.green[600],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Track statistics
                Row(
                  children: [
                   
                    _buildStatItem(
                      icon: Icons.quiz_outlined,
                      count: totalExams,
                      label: totalExams == 1 ? 'Exam' : 'Exams',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.green[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getTrackIcon(String trackName) {
    switch (trackName.toLowerCase()) {
      case 'mobile development':
        return Icons.smartphone;
      case 'web development':
        return Icons.web;
      case 'data science':
        return Icons.analytics;
      case 'devops':
        return Icons.settings;
      case 'artificial intelligence':
      case 'ai':
        return Icons.psychology;
      case 'cybersecurity':
        return Icons.security;
      case 'cloud computing':
        return Icons.cloud;
      case 'blockchain':
        return Icons.currency_bitcoin;
      default:
        return Icons.school;
    }
  }

  void _onTrackSelected(Track track) {
  try {
    print("🎯 Track selected: ${track.name} with ${track.courses.length} courses");

    // Collect all exams from this track
    final exams = track.courses
        .expand((course) => course.exams ?? [])
        .toList();

    if (exams.isEmpty) {
      Get.snackbar(
        "No Exams",
        "This track has no exams available",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // 👇 Navigate directly to Exam Page
    Get.to(
      () => CourseSelectionView(exams: exams, track: track),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

  } catch (e) {
    print("❌ Error selecting track: $e");
    Get.snackbar(
      "Error",
      "Failed to load track: ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
}