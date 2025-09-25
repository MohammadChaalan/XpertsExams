import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';

class TestController extends GetxController {
  // Dependencies
  SignInController? _signInController;
  late Dio _dio;

  // Observable variables
  final RxList<Question> questions = <Question>[].obs;
  final RxMap<int, String> selectedAnswers = <int, String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool examFinished = false.obs;
  final RxMap<String, dynamic> lastResult = <String, dynamic>{}.obs;
  final RxString currentCourseTitle = ''.obs;
  final RxInt timeSpent = 0.obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  /// Initialize controller dependencies
  void _initializeController() {
    try {
      _signInController = Get.find<SignInController>();
      _dio = DioClient().getInstance();
      
      print("Test controller initialized successfully");
    } catch (e) {
      _handleError("Failed to initialize test controller", e);
    }
  }

  /// Load questions for a specific course
  Future<void> loadQuestions(String courseTitle) async {
    if (_signInController == null) {
      _handleError("Controller not properly initialized", null);
      return;
    }

    // Check if exam is already finished for this course
    if (examFinished.value && currentCourseTitle.value == courseTitle) {
      _showPreviousResult();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      currentCourseTitle.value = courseTitle;

      // Load questions from sign-in controller
      final loadedQuestions = _signInController!.getQuestionsByCourse(courseTitle);
      
      if (loadedQuestions.isEmpty) {
        throw Exception("No questions found for course: $courseTitle");
      }

      // Update state
      questions.assignAll(loadedQuestions);
      selectedAnswers.clear();
      examFinished.value = false;
      timeSpent.value = 0;

      print("Loaded ${loadedQuestions.length} questions for '$courseTitle'");
      
    } catch (e) {
      _handleError("Failed to load questions for $courseTitle", e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Select an answer for a question
  void selectAnswer(int questionIndex, String answer) {
    try {
      if (questionIndex < 0 || questionIndex >= questions.length) {
        throw RangeError("Invalid question index: $questionIndex");
      }

      if (answer.isEmpty) {
        throw ArgumentError("Answer cannot be empty");
      }

      selectedAnswers[questionIndex] = answer;
      print("Answer selected for Q${questionIndex + 1}: $answer");
      
    } catch (e) {
      _handleError("Failed to select answer", e);
    }
  }

  /// Get selected answer for a question
  String? getSelectedAnswer(int questionIndex) {
    try {
      if (questionIndex < 0 || questionIndex >= questions.length) {
        return null;
      }
      return selectedAnswers[questionIndex];
    } catch (e) {
      return null;
    }
  }

  /// Check if all questions are answered
  bool get areAllQuestionsAnswered {
    return selectedAnswers.length == questions.length &&
           selectedAnswers.values.every((answer) => answer.isNotEmpty);
  }

  /// Get progress percentage (answered questions)
  double get progressPercentage {
    if (questions.isEmpty) return 0.0;
    return (selectedAnswers.length / questions.length) * 100;
  }

  /// Submit test and calculate results
  Future<void> submitTest({bool autoSubmit = false}) async {
    try {
      if (questions.isEmpty) {
        throw Exception("No questions available to submit");
      }

      if (examFinished.value) {
        _showPreviousResult();
        return;
      }

      isLoading.value = true;

      // Calculate results
      final results = _calculateResults();
      
      // Get auth token
      final token = await _getAuthToken();
      
      // Prepare result data
      final resultData = {
        "score": results['correctAnswers'],
        "total": results['totalQuestions'],
        "percentage": results['percentage'],
        "autoSubmit": autoSubmit,
        "courseTitle": currentCourseTitle.value,
        "timeSpent": timeSpent.value,
        "questions": questions.toList(),
        "selectedAnswers": selectedAnswers(),
        "token": token,
      };

      // Store result
      lastResult.assignAll(resultData);
      examFinished.value = true;

      // Submit to backend (don't wait for it to complete)
      _submitToBackend(resultData);

      // Navigate to results immediately
      Get.offNamed(AppRoute.result, arguments: resultData);

      print("Test submitted: ${results['correctAnswers']}/${results['totalQuestions']} (${results['percentage']}%)");

    } catch (e) {
      _handleError("Failed to submit test", e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate test results
  Map<String, int> _calculateResults() {
    int correctAnswers = 0;
    
    for (int i = 0; i < questions.length; i++) {
      final selectedAnswer = selectedAnswers[i];
      final correctAnswer = questions[i].answer;

      if (selectedAnswer != null && 
          selectedAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
        correctAnswers++;
      }
    }

    final totalQuestions = questions.length;
    final percentage = totalQuestions > 0 
        ? ((correctAnswers / totalQuestions) * 100).round() 
        : 0;

    return {
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
    };
  }

  /// Submit results to backend (fire and forget)
  void _submitToBackend(Map<String, dynamic> resultData) async {
    try {
      isSubmitting.value = true;
      
      final token = resultData['token'] as String;
      if (token.isEmpty) {
        print("Warning: No auth token available for backend submission");
        return;
      }

      // Prepare answers array in the same order as questions
      final List<Question> questionsList = List<Question>.from(resultData['questions']);
      final Map<int, String> answersMap = Map<int, String>.from(resultData['selectedAnswers']);
      
      final answers = questionsList.asMap().entries.map((entry) {
        final index = entry.key;
        return answersMap[index];
      }).toList();

      // Make API request
      final response = await _dio.post(
        '/submit-test',
        data: {
          'courseTitle': resultData['courseTitle'],
          'answers': answers,
          'timeSpent': resultData['timeSpent'],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Result successfully submitted to backend");
      
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to submit test result',
        );
      }

    } on DioException catch (e) {
      print("Backend submission failed (DioException): ${_getDioErrorMessage(e)}");
    } catch (e) {
      print("Backend submission failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Get user-friendly error message from DioException
  String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 'Server error';
        
        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return 'Authentication failed. Please login again.';
          case 403:
            return 'Access denied: $message';
          case 404:
            return 'Resource not found: $message';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'HTTP $statusCode: $message';
        }
      
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      
      case DioExceptionType.unknown:
      default:
        if (error.error.toString().contains('SocketException')) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error: ${error.message}';
    }
  }

  /// Get authentication token
  Future<String> _getAuthToken() async {
    try {
      return await _signInController?.getAuthToken() ?? '';
    } catch (e) {
      print("Warning: Failed to get auth token: $e");
      return '';
    }
  }

  /// Show previous result
  void _showPreviousResult() {
    if (lastResult.isNotEmpty) {
      Get.offNamed(AppRoute.result, arguments: Map<String, dynamic>.from(lastResult));
    } else {
      Get.snackbar(
        "No Previous Result",
        "No previous test result found",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Reset test state
  void resetTest() {
    try {
      questions.clear();
      selectedAnswers.clear();
      examFinished.value = false;
      lastResult.clear();
      currentCourseTitle.value = '';
      timeSpent.value = 0;
      hasError.value = false;
      errorMessage.value = '';
      isSubmitting.value = false;
      
      print("Test state reset");
    } catch (e) {
      print("Error resetting test state: $e");
    }
  }

  /// Handle errors consistently
  void _handleError(String message, dynamic error) {
    hasError.value = true;
    errorMessage.value = message;
    
    
  }

  /// Clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Retry last failed operation
  void retryLastOperation() {
    clearError();
    if (currentCourseTitle.value.isNotEmpty) {
      loadQuestions(currentCourseTitle.value);
    }
  }

  /// Get test summary
  Map<String, dynamic> get testSummary {
    return {
      'totalQuestions': questions.length,
      'answeredQuestions': selectedAnswers.length,
      'unansweredQuestions': questions.length - selectedAnswers.length,
      'progressPercentage': progressPercentage,
      'courseTitle': currentCourseTitle.value,
      'timeSpent': timeSpent.value,
      'isFinished': examFinished.value,
      'isSubmitting': isSubmitting.value,
    };
  }

  /// Update time spent (call this from a timer in your view)
  void updateTimeSpent(int seconds) {
    timeSpent.value = seconds;
  }

  /// Get backend submission status
  String get submissionStatus {
    if (isSubmitting.value) {
      return "Submitting to server...";
    }
    return "Ready";
  }

  /// Retry backend submission
  Future<void> retryBackendSubmission() async {
    if (lastResult.isNotEmpty) {
      _submitToBackend(Map<String, dynamic>.from(lastResult));
    }
  }

  @override
  void onClose() {
    try {
      resetTest();
      super.onClose();
    } catch (e) {
      print("Error during controller cleanup: $e");
    }
  }
}