import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Controllers/Test/TestController.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class CourseSelectionView extends StatefulWidget {
  final List exams;
  final Track track;

  const CourseSelectionView({
    super.key,
    required this.exams,
    required this.track,
  });

  @override
  State<CourseSelectionView> createState() => _CourseSelectionViewState();
}

class _CourseSelectionViewState extends State<CourseSelectionView> {
  late SignInController signInController;

  @override
  void initState() {
    super.initState();
    signInController = Get.find<SignInController>();
  }

  void _onCourseSelected(String course) async {
    try {
      final questions = signInController.getQuestionsByCourse(course);

      if (questions.isEmpty) {
        Get.snackbar(
          "No Questions",
          "This course doesn't have any questions available yet.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (Get.isRegistered<TestController>()) {
        Get.delete<TestController>(force: true);
      }

      final testController = Get.put(TestController(), permanent: true);

      await Future.delayed(const Duration(milliseconds: 50));
      testController.loadQuestions(course);

      Get.toNamed(AppRoute.test, arguments: {
        "course": course,
        "track": widget.track,
        "exams": widget.exams,
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load course: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.track.courses;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.track.name),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text(
                "No courses available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: () => _onCourseSelected(course.title),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFE8F5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.book, color: Colors.green),
                      ),
                      title: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${signInController.getQuestionsByCourse(course.title).length} questions",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.green),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
