import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Views/tracks/track_view.dart';

class AcademyView extends StatelessWidget {
  AcademyView({super.key});

  final SignInController signInController = Get.find<SignInController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Tracks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.track_changes),
                    SizedBox(width: 5),
                    Text(
                      "My Tracks",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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

            /// Track List
            Obx(() {
              final tracks = signInController.user.value?.tracks ?? [];
              if (tracks.isEmpty) {
                return const Text("No tracks available");
              }
              return SizedBox(
                height: 170,
                child: ListView.builder(
                  itemCount: tracks.length,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _buildTrackCard(track, context);
                  },
                ),
              );
            }),

            const SizedBox(height: 20),

            /// Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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

            const SizedBox(height: 20),

            /// Scheduled Sessions
            const Row(
              children: [
                Icon(Icons.schedule),
                SizedBox(width: 5),
                Text(
                  "Scheduled Sessions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: _buildScheduledSession(),
            ),

            const SizedBox(height: 20),

            /// Documents & Certificates
            const Text(
              "Documents & Certificates",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildDocumentCard(
                  title: "Certificate of Completion",
                  leading: const Icon(Icons.insert_drive_file,
                      color: Colors.green),
                  subtitle: "PDF / Certificate",
                  buttonText: "Download",
                  onTrailingPressed: () {
                    print("Download certificate tapped!");
                  },
                  onTap: () {
                    print("Card tapped!");
                  },
                ),
                _buildDocumentCard(
                  title: "Project Document",
                  leading:
                      const Icon(Icons.insert_drive_file, color: Colors.blue),
                  subtitle: "Word / Doc",
                  buttonText: "Share",
                  onTrailingPressed: () {
                    print("Share document tapped!");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(Track track, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackCoursesView(track: track),
          ),
        );
      },
      child: Container(
        width: 200,
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
              child: const Icon(Icons.play_lesson),
            ),
            const SizedBox(height: 10),
            Text(track.name, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
           const Text("Go to complete all the lessons" , 
            style: TextStyle(fontSize: 12 , color: Colors.green , fontWeight: FontWeight.bold),

            
            ),

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
              offset: const Offset(0, 4)),
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledSession() {
    return const Column(
      children: [
        SizedBox(height: 10),
        Icon(Icons.calendar_today_rounded, size: 50, color: Colors.grey),
        SizedBox(height: 15),
        Text(
          "No Upcoming Sessions",
          style:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Check back later for scheduled learning session",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required Icon leading,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTrailingPressed,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        leading: leading,
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: TextButton(
          onPressed: onTrailingPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.green),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
