import 'package:flutter/material.dart';
import 'package:xpertexams/Views/Demo/track_offline_view.dart';

class AcademyViewOffline extends StatefulWidget {
  const AcademyViewOffline({super.key});

  @override
  State<AcademyViewOffline> createState() =>
      _AcademyViewOfflineDesignState();
}

class _AcademyViewOfflineDesignState extends State<AcademyViewOffline> {
  bool isLoading = true;

  /// ---------------- Offline Local Data ----------------
  final List<Map<String, dynamic>> tracks = [
    {
      "id": 1,
      "name": "Flutter Track",
      "description": "Learn Flutter from basics to advanced",
      "courses": [
        {
          "id": 101,
          "title": "Flutter Basics",
          "description": "Introduction to Flutter and Dart",
          "videos": [
            {"title": "Flutter Setup", "duration": "5 min", "isCompleted": false},
            {"title": "Hello World App", "duration": "10 min", "isCompleted": false},
          ],
        },
        {
          "id": 102,
          "title": "Flutter Widgets",
          "description": "Learn about common Flutter widgets",
          "videos": [
            {"title": "Text & Images", "duration": "8 min", "isCompleted": false},
            {"title": "Buttons & Forms", "duration": "12 min", "isCompleted": false},
          ],
        },
      ],
    },
    {
      "id": 2,
      "name": "Dart Track",
      "description": "Master Dart programming language",
      "courses": [
        {
          "id": 201,
          "title": "Dart Basics",
          "description": "Variables, Types, Functions",
          "videos": [
            {"title": "Variables", "duration": "6 min", "isCompleted": false},
            {"title": "Functions", "duration": "9 min", "isCompleted": false},
          ],
        },
        {
          "id": 202,
          "title": "Advanced Dart",
          "description": "Collections, Futures, Streams",
          "videos": [
            {"title": "Lists & Maps", "duration": "7 min", "isCompleted": false},
            {"title": "Async Programming", "duration": "15 min", "isCompleted": false},
          ],
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  void _loadLocalData() {
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  double _calculateCourseProgress(Map<String, dynamic> course) {
    final videos = course["videos"] as List<dynamic>;
    if (videos.isEmpty) return 0.0;
    final completed = videos.where((v) => v["isCompleted"] == true).length;
    return completed / videos.length;
  }

  double _calculateTrackProgress(Map<String, dynamic> track) {
    final courses = track["courses"] as List<dynamic>;
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
      child: Text(
        "${(progress * 100).toStringAsFixed(0)}%",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTrackCard(Map<String, dynamic> track) {
    final progress = _calculateTrackProgress(track);
    return InkWell(
      onTap: () {
        // Navigate to offline track view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackCoursesOfflineView(track: track),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.play_lesson, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(track["name"],
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.green[200],
              color: Colors.green,
            ),
            const SizedBox(height: 6),
            _buildProgressChip(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: Colors.green, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.track_changes),
                  SizedBox(width: 5),
                  Text("My Tracks",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(),
                  ),
                  child: const Text("All tracks >"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          /// Horizontal Track List
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              itemBuilder: (context, index) => _buildTrackCard(tracks[index]),
            ),
          ),

          const SizedBox(height: 20),

          /// Quick Actions
          const Text("Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickAction(Icons.history, "Checking History"),
              _buildQuickAction(Icons.calendar_today, "View Tasks"),
              _buildQuickAction(Icons.chat, "Chat"),
              _buildQuickAction(Icons.announcement, "Announcements"),
              _buildQuickAction(Icons.newspaper, "News"),
              _buildQuickAction(Icons.video_call, "Book Session"),
            ],
          ),
        ]),
      ),
    );
  }
}
