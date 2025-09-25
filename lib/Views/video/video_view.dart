// import 'package:flutter/material.dart';
// import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
// import 'package:xpertexams/Models/CourseModel.dart';
// import 'package:xpertexams/Models/TrackModel.dart';
// import 'package:xpertexams/Models/VideoModel.dart';
// import 'package:xpertexams/Views/tracks/video_player_view.dart';

// class TrackAllVideosPage extends StatefulWidget {
//   final Track? track; // nullable

//   const TrackAllVideosPage({super.key, this.track});

//   @override
//   State<TrackAllVideosPage> createState() => _TrackAllVideosPageState();
// }

// class _TrackAllVideosPageState extends State<TrackAllVideosPage> {
//   List<Map<String, dynamic>> allVideos = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadAllVideos();
//   }

//   Future<void> _loadAllVideos() async {
//     allVideos.clear();

//     if (widget.track == null) {
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }

//     for (final course in widget.track!.courses) {
//       for (final video in course.video) {
//         // Load local completion status
//         await video.loadCompletionStatus();

//         allVideos.add({
//           'video': video,
//           'courseId': course.id,
//         });
//       }
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> _handleVideoTap(Video video, int courseId) async {
//     if (!video.hasValidUrl) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Video URL not available"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => VideoContentPage(
//           videoUrl: video.url!,
//           title: video.title,
//           videoId: video.id,
//           courseId: courseId,
//         ),
//       ),
//     );

//     if (result == true) {
//       await video.markAsCompleted(syncToBackend: false);
//       await video.refreshCompletionStatus();
//       if (mounted) setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final trackName = widget.track?.name ?? "No Track Selected";

  
//   return Scaffold(
//       appBar: AppBar(
//         title: Text("Videos - $trackName"),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : allVideos.isEmpty
//               ? const Center(child: Text("No videos available"))
//               : ListView.builder(
//                   itemCount: allVideos.length,
//                   itemBuilder: (context, index) {
//                     final video = allVideos[index]['video'] as Video;
//                     final courseId = allVideos[index]['courseId'] as int;

//                     return ListTile(
//                       leading: Icon(
//                         video.isCompleted
//                             ? Icons.check_circle
//                             : Icons.play_circle_fill,
//                         color: video.isCompleted ? Colors.green : Colors.blue,
//                       ),
//                       title: Text(video.title),
//                       subtitle: Text("Duration: ${video.duration}"),
//                       trailing: video.isCompleted
//                           ? const Text(
//                               "Completed",
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : null,
//                       onTap: () => _handleVideoTap(video, courseId),
//                     );
//                   },
//                 ),
//                 bottomNavigationBar: CustomBottomBarPage(),
//     );
//   }
// }
