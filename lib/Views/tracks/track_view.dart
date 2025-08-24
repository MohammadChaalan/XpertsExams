import 'package:flutter/material.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Models/CourseModel.dart';
import 'package:xpertexams/Models/VideoModel.dart';
import 'package:xpertexams/Views/tracks/video_player_view.dart';

class TrackCoursesView extends StatelessWidget {
  final Track track;

  const TrackCoursesView({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        centerTitle: true,
        title: Text(
          track.name,
          style: const TextStyle(fontWeight: FontWeight.bold , color: Colors.white),

        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: track.courses.length,
        itemBuilder: (context, index) {
          final Course course = track.courses[index];

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
              title: Text(
                course.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              subtitle: course.description != null && course.description!.isNotEmpty
                  ? Text(
                      course.description!,
                      style: const TextStyle(color: Colors.black54),
                    )
                  : null,
              children: course.video.map((Video video) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: const Icon(Icons.play_circle_fill, color: Colors.green),
                    title: Text(
                      video.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text("Duration: ${video.duration}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                    onTap: () {
                      if (video.url != null && video.url!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoContentPage(
                              videoUrl: video.url!,
                              title: video.title,
                            ),
                          ),
                        );
                      } else {
                        debugPrint("❌ No video URL found");
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
