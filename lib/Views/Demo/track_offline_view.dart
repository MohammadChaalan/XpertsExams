import 'package:flutter/material.dart';

class TrackCoursesOfflineView extends StatefulWidget {
  final Map<String, dynamic> track;

  const TrackCoursesOfflineView({super.key, required this.track});

  @override
  State<TrackCoursesOfflineView> createState() => _TrackCoursesOfflineViewState();
}

class _TrackCoursesOfflineViewState extends State<TrackCoursesOfflineView> {
  double _calculateCourseProgress(Map<String, dynamic> course) {
    final videos = course["videos"] as List<dynamic>;
    if (videos.isEmpty) return 0.0;
    final completed = videos.where((v) => v["isCompleted"] == true).length;
    return completed / videos.length;
  }

  double _calculateTrackProgress() {
    final courses = widget.track["courses"] as List<dynamic>;
    int totalVideos = 0, completedVideos = 0;
    for (final course in courses) {
      final videos = course["videos"] as List<dynamic>;
      totalVideos += videos.length;
      completedVideos += videos.where((v) => v["isCompleted"] == true).length;
    }
    return totalVideos > 0 ? completedVideos / totalVideos : 0.0;
  }

  Widget _buildProgressChip(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: progress == 1 ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("${(progress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildVideoTile(Map<String, dynamic> video) {
    return ListTile(
      title: Text(video["title"]),
      trailing: Text(video["duration"]),
      leading: CircleAvatar(
        backgroundColor: video["isCompleted"] ? Colors.green[700] : Colors.green,
        child: Icon(
          video["isCompleted"] ? Icons.check : Icons.play_arrow,
          color: Colors.white,
          size: 16,
        ),
      ),
      onTap: () {
        setState(() {
          video["isCompleted"] = true; // mark video completed
        });
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final progress = _calculateCourseProgress(course);
    final videos = course["videos"] as List<dynamic>;
    return Card(
      color: Colors.green[50],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircularProgressIndicator(
          value: progress,
          backgroundColor: Colors.green[200],
          valueColor: AlwaysStoppedAnimation<Color>(progress == 1 ? Colors.green[700]! : Colors.green),
        ),
        title: Text(course["title"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((course["description"] ?? "").isNotEmpty)
              Text(course["description"], style: const TextStyle(color: Colors.black54)),
            Text(
              "${videos.where((v) => v["isCompleted"] == true).length}/${videos.length} videos completed",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        trailing: _buildProgressChip(progress),
        children: videos.map<Widget>((v) => _buildVideoTile(v)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackProgress = _calculateTrackProgress();
    final courses = widget.track["courses"] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        centerTitle: true,
        title: Text(widget.track["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Track Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: trackProgress, backgroundColor: Colors.green[200], color: Colors.green),
                  const SizedBox(height: 4),
                  Text("${(trackProgress * 100).toStringAsFixed(0)}% Complete"),
                ],
              ),
            ),
          ),
          ...courses.map((c) => _buildCourseCard(c)).toList(),
        ],
      ),
    );
  }
}
