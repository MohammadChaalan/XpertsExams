import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class TestController extends GetxController {
  SignInController? _signInController;
  late Dio dio;
  final RxList<Question> questions = <Question>[].obs;
  final RxMap<int, String> selectedAnswers = <int, String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool examFinished = false.obs;
  final RxMap<String, dynamic> lastResult = <String, dynamic>{}.obs;
  final RxString currentCourseTitle = ''.obs;
  final RxInt timeSpent = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool isSubmitting = false.obs;

  

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    try {
      _signInController = Get.find<SignInController>();
    } catch (e) {
      _handleError("Failed to initialize TestController", e);
    }
  }

  Future<void> loadQuestions(String courseTitle) async {
    if (_signInController == null) {
      _handleError("Controller not properly initialized", null);
      return;
    }

    if (examFinished.value && currentCourseTitle.value == courseTitle) {
      _showPreviousResult();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      currentCourseTitle.value = courseTitle;

      final loadedQuestions = _signInController!.getQuestionsByCourse(courseTitle);

      if (loadedQuestions.isEmpty) {
        throw Exception("No questions found for course: $courseTitle");
      }

      questions.assignAll(loadedQuestions);
      selectedAnswers.clear();
      examFinished.value = false;
      timeSpent.value = 0;
    } catch (e) {
      _handleError("Failed to load questions", e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(int questionIndex, String answer) {
    if (questionIndex < 0 || questionIndex >= questions.length) return;
    selectedAnswers[questionIndex] = answer;
  }

  String? getSelectedAnswer(int questionIndex) => selectedAnswers[questionIndex];

  bool get areAllQuestionsAnswered =>
      selectedAnswers.length == questions.length &&
      selectedAnswers.values.every((a) => a.isNotEmpty);

  double get progressPercentage =>
      questions.isEmpty ? 0.0 : (selectedAnswers.length / questions.length) * 100;

  Future<void> submitTest({bool autoSubmit = false}) async {
    if (questions.isEmpty) {
      _handleError("No questions to submit", null);
      return;
    }

    if (examFinished.value) {
      _showPreviousResult();
      return;
    }

    isLoading.value = true;

    try {
      final results = _calculateResults();
      final token = await _getAuthToken();

      final resultData = {
        "score": results['correctAnswers'],
        "total": results['totalQuestions'],
        "percentage": results['percentage'],
        "autoSubmit": autoSubmit,
        "courseTitle": currentCourseTitle.value,
        "timeSpent": timeSpent.value,
        "questions": questions.toList(),
        "selectedAnswers": Map<int, String>.from(selectedAnswers),
        "token": token ?? '',
      };

      lastResult.assignAll(resultData);
      examFinished.value = true;

      // Fire and forget backend submission
      _submitToBackend(resultData);

      Get.offNamed(AppRoute.result, arguments: resultData);
    } catch (e) {
      _handleError("Failed to submit test", e);
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, int> _calculateResults() {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      final selected = selectedAnswers[i];
      if (selected != null &&
          selected.trim().toLowerCase() == questions[i].answer.trim().toLowerCase()) {
        correct++;
      }
    }
    return {
      'correctAnswers': correct,
      'totalQuestions': questions.length,
      'percentage': questions.isEmpty ? 0 : ((correct / questions.length) * 100).round(),
    };
  }

  Future<String> _getAuthToken() async {
    try {
      return await _signInController?.getAuthToken() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _submitToBackend(Map<String, dynamic> data) async {
    if (data['token'] == null || (data['token'] as String).isEmpty) return;

    try {
      await dio.post('/submit-test',
          data: {'courseTitle': data['courseTitle'], 'answers': data['selectedAnswers'], 'timeSpent': data['timeSpent']},
          options: Options(headers: {'Authorization': 'Bearer ${data['token']}'}));
    } catch (e) {
      print("Backend submission failed: $e");
    }
  }

  void resetTest() {
    questions.clear();
    selectedAnswers.clear();
    examFinished.value = false;
    lastResult.clear();
    currentCourseTitle.value = '';
    timeSpent.value = 0;
    hasError.value = false;
    errorMessage.value = '';
    isSubmitting.value = false;
  }

  void _handleError(String message, dynamic e) {
    hasError.value = true;
    errorMessage.value = message;
  }

  void _showPreviousResult() {
    if (lastResult.isNotEmpty) {
      Get.offNamed(AppRoute.result, arguments: Map<String, dynamic>.from(lastResult));
    }
  }
}
