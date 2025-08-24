import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:flutter/material.dart';

class TestController extends GetxController {
  late final SignInController signInController;

  var questions = <Question>[].obs;
  var selectedAnswers = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Safely get the SignInController
    try {
      signInController = Get.find<SignInController>();
    } catch (e) {
      print("Error finding SignInController: $e");
    }
  }

  /// Load questions for a specific course
  void loadQuestions(String courseTitle) {
    try {
      // questions.value = signInController.getQuestionsByCourse(courseTitle);
      selectedAnswers.clear();
    } catch (e) {
      print("Error loading questions: $e");
      Get.snackbar("Error", "Failed to load questions");
    }
  }

  void selectAnswer(int index, String answer) {
    selectedAnswers[index] = answer;
  }

  void submit() {
    if (questions.isEmpty) {
      Get.snackbar("Error", "No questions available");
      return;
    }

    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].answer) correct++;
    }

    Get.snackbar(
      "Result",
      "You scored $correct/${questions.length}",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}