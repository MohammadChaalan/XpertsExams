import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class TestController extends GetxController {
  SignInController? _signInController;

  var questions = <Question>[].obs;
  var selectedAnswers = <int, String>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    try {
      _signInController = Get.find<SignInController>();
      print("✅ SignInController found successfully");
    } catch (e) {
      print("❌ Error finding SignInController: $e");
      Get.snackbar("Error", "Unable to initialize test controller");
    }
  }

  void loadQuestions(String courseTitle) {
    if (_signInController == null) {
      print("❌ SignInController not available");
      Get.snackbar("Error", "Controller not initialized");
      return;
    }

    try {
      isLoading.value = true;
      final loadedQuestions = _signInController!.getQuestionsByCourse(courseTitle);
      questions.value = loadedQuestions;
      selectedAnswers.clear();
      print("✅ Loaded ${loadedQuestions.length} questions for '$courseTitle'");
    } catch (e) {
      print("❌ Error loading questions: $e");
      Get.snackbar("Error", "Failed to load questions: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(int index, String answer) {
    if (index >= 0 && index < questions.length) {
      selectedAnswers[index] = answer;
      print("📝 Answer selected for Q${index + 1}: $answer");
    }
  }

  /// Updated submit method with auto flag
  void submit({bool auto = false}) {
  if (questions.isEmpty) {
    Get.snackbar("Error", "No questions available");
    return;
  }

  int correct = 0;
  for (int i = 0; i < questions.length; i++) {
    final selectedAnswer = selectedAnswers[i];
    final correctAnswer = questions[i].answer;

    if (selectedAnswer != null &&
        selectedAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      correct++;
    }
  }

  final percentage = ((correct / questions.length) * 100).round();

  // Navigate to Result page
  Get.offNamed(AppRoute.result, arguments: {
  "score": correct,
  "total": questions.length,
  "percentage": percentage,
  "autoSubmit": auto,
  "questions": questions,
  "selectedAnswers": selectedAnswers,
});


  print("📊 Test completed: $correct/${questions.length} ($percentage%)");
}


  void _calculateAndShowResult({bool autoSubmit = false}) {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      final selectedAnswer = selectedAnswers[i];
      final correctAnswer = questions[i].answer;
      if (selectedAnswer != null && selectedAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
        correct++;
      }
    }

    final percentage = ((correct / questions.length) * 100).round();

    // Show result dialog only if not auto-submit
    if (!autoSubmit) {
      Get.dialog(
        AlertDialog(
          title: const Text("Test Result"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Score: $correct/${questions.length}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Percentage: $percentage%",
                  style: TextStyle(fontSize: 16, color: percentage >= 70 ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to course selection
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Auto-submit: go back after short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (Get.isOverlaysOpen) Get.back(); // Close dialog if any
         Get.back(); // Go back to previous page
      });
    }

    print("📊 Test completed: $correct/${questions.length} ($percentage%)");
  }

  @override
  void onClose() {
    questions.clear();
    selectedAnswers.clear();
    super.onClose();
  }
}
