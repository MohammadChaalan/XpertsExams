import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Views/tracks/track_view.dart';
import 'package:xpertexams/Views/widgets/certificate_service.dart';

class AcademyView extends StatefulWidget {
  AcademyView({super.key});

  @override
  State<AcademyView> createState() => _AcademyViewState();
}

class _AcademyViewState extends State<AcademyView> {
  final SignInController signInController = Get.find<SignInController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(Icons.track_changes, "My Tracks"),
              const SizedBox(height: 10),
              _buildTrackList(),

              const SizedBox(height: 20),
              _buildSectionTitle(Icons.flash_on, "Quick Actions"),
              const SizedBox(height: 10),
              _buildQuickActions(),

              const SizedBox(height: 20),
              _buildSectionTitle(Icons.schedule, "Scheduled Sessions"),
              const SizedBox(height: 10),
              _buildScheduledSession(),

              const SizedBox(height: 20),
              _buildSectionTitle(Icons.insert_drive_file, "Documents & Certificates"),
              const SizedBox(height: 10),
              _buildDocuments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTrackList() {
    return Obx(() {
      final tracks = signInController.user.value?.tracks ?? [];
      if (tracks.isEmpty) {
        return const Center(
          child: Text(
            "No tracks available",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return SizedBox(
        height: 160,
        
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tracks.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _buildTrackCard(track);
          },
        ),
      );
    });
  }

  Widget _buildTrackCard(Track track) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrackCoursesView(track: track)),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.play_lesson, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(track.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              "Complete all lessons",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {"icon": Icons.history, "title": "Checking History", "color": Colors.purple},
      {"icon": Icons.calendar_today, "title": "View Tasks", "color": Colors.red},
      {"icon": Icons.chat, "title": "Chat", "color": Colors.blue},
      {"icon": Icons.announcement, "title": "Announcements", "color": Colors.orange},
      {"icon": Icons.newspaper, "title": "News", "color": Colors.green},
      {"icon": Icons.video_call, "title": "Book Session", "color": Colors.yellow.shade700},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildQuickAction(action["icon"] as IconData, action["title"] as String,
            action["color"] as Color);
      },
    );
  }

  Widget _buildQuickAction(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.alpha < 100 ? color.withOpacity(0.3) : color.withOpacity(0.1), width: 1.5),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color:color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledSession() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.calendar_today_rounded, size: 50, color: Colors.grey),
          SizedBox(height: 15),
          Text(
            "No Upcoming Sessions",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Check back later for scheduled learning session",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments() {
    return Column(
      children: [
        _buildDocumentCard(
          title: "Project Certificate",
          leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
          subtitle: "PDF / Certificate",
          buttonText: "Generate",
          onTrailingPressed: () async {
            final Uint8List pdfData = await CertificateService.generateCertificate(
              studentName: "${signInController.user.value?.name ?? 'User'}",
              courseName: "Flutter Development",
              date:
                  "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
            );

            await Printing.layoutPdf(onLayout: (format) async => pdfData);
          },
        ),
        _buildDocumentCard(
          title: "Project Document",
          leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
          subtitle: "Word / Doc",
          buttonText: "Share",
          onTrailingPressed: () {
            print("Share document tapped!");
          },
        ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.green.withOpacity(0.3),
      child: ListTile(
        leading: leading,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onTrailingPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(buttonText, style: const TextStyle(color: Colors.white)),
        ),
        onTap: onTap,
      ),
    );
  }
}
