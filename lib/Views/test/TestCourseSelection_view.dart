import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Controllers/Test/TestController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class CourseSelectionView extends StatelessWidget {
  CourseSelectionView({super.key});

  final SignInController signInController = Get.find();

  @override
  Widget build(BuildContext context) {
    // final courses = signInController.getCourses();

    return Scaffold(
      appBar: AppBar(title: const Text("Select Course")),
    //   body: courses.isEmpty
    //       ? const Center(
    //           child: Text(
    //             "No courses available",
    //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //           ),
    //         )
    //       : ListView.separated(
    //           padding: const EdgeInsets.all(16),
    //           itemCount: courses.length,
    //           separatorBuilder: (_, __) => const SizedBox(height: 10),
    //           itemBuilder: (context, index) {
    //             final course = courses[index];
    //             return Card(
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(12),
    //               ),
    //               elevation: 2,
    //               child: ListTile(
    //                 contentPadding: const EdgeInsets.symmetric(
    //                   horizontal: 16,
    //                   vertical: 12,
    //                 ),
    //                 title: Text(
    //                   course,
    //                   style: const TextStyle(
    //                     fontWeight: FontWeight.w600,
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 trailing: const Icon(Icons.arrow_forward_ios, size: 18),
    //                 onTap: () {
    //                   // Put TestController into GetX container before navigating
    //                   Get.put(TestController());
                      
    //                   // Get the TestController and load questions
    //                   final testController = Get.find<TestController>();
    //                   testController.loadQuestions(course);
                      
    //                   Get.toNamed(AppRoute.test);
    //                 },
    //               ),
    //             );
    //           },
    //         ),
    );
  }
}