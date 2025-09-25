import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class ResultView extends StatefulWidget {
  const ResultView({super.key});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isSubmitting = false;
  bool _submissionSuccess = false;
  String? _submissionError;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _submitResult();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  Future<void> _submitResult() async {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final token = args["token"] ?? "";
    final courseTitle = args["courseTitle"] ?? "Unknown Course";
    final Map<int, String> selectedAnswers = (args["selectedAnswers"] ?? {}) as Map<int, String>;
    final List<Question> questions = args["questions"] ?? [];
    final timeSpent = args["timeSpent"] ?? 0;

    if (token.isEmpty || questions.isEmpty) return;

    try {
      setState(() => _isSubmitting = true);

      final dio = Dio();
      final answers = questions.map((q) {
        return selectedAnswers[questions.indexOf(q)];
      }).toList();

      final response = await DioClient().getInstance().post(
        "/submit-test",
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
        data: {
          "courseTitle": courseTitle,
          "answers": answers,
          "timeSpent": timeSpent,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _submissionSuccess = true;
          _isSubmitting = false;
        });
        print("Result submitted successfully: ${response.data}");
      }
    } catch (e) {
      setState(() {
        _submissionError = "Failed to submit result. Please try again.";
        _isSubmitting = false;
      });
      print("Error submitting result: $e");
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final score = args["score"] ?? 0;
    final total = args["total"] ?? 0;
    final percentage = args["percentage"] ?? 0;
    final autoSubmit = args["autoSubmit"] ?? false;
    final courseTitle = args["courseTitle"] ?? "Unknown Course";
    final timeSpent = args["timeSpent"] ?? 0;
    final List<Question> questions = args["questions"] ?? [];
    final Map<int, String> selectedAnswers = (args["selectedAnswers"] ?? {}) as Map<int, String>;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              percentage >= 70 ? Colors.green[400]! : 
              percentage >= 50 ? Colors.orange[400]! : Colors.red[400]!,
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(autoSubmit, courseTitle),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildScoreSection(score, total, percentage, timeSpent),
                      _buildSubmissionStatus(),
                      _buildQuestionsReview(questions, selectedAnswers),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool autoSubmit, String courseTitle) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  autoSubmit ? Icons.timer_off_rounded : Icons.celebration_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                autoSubmit ? "Time's Up!" : "Exam Completed!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                courseTitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(int score, int total, int percentage, int timeSpent) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Card(
            elevation: 12,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 80.0,
                    lineWidth: 12.0,
                    percent: percentage / 100,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$percentage%",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: percentage >= 70 ? Colors.green[600] : 
                                   percentage >= 50 ? Colors.orange[600] : Colors.red[600],
                          ),
                        ),
                        Text(
                          _getGradeText(percentage),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    progressColor: percentage >= 70 ? Colors.green[500] : 
                                   percentage >= 50 ? Colors.orange[500] : Colors.red[500],
                    backgroundColor: Colors.grey[200]!,
                    animation: true,
                    animationDuration: 1500,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Score", "$score/$total", Icons.quiz_rounded),
                        _buildStatDivider(),
                        _buildStatItem("Time", _formatTime(timeSpent), Icons.access_time_rounded),
                        _buildStatDivider(),
                        _buildStatItem("Accuracy", "${((score/total)*100).toInt()}%", Icons.check_circle_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: percentage >= 70 ? Colors.green[50] : 
                             percentage >= 50 ? Colors.orange[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: percentage >= 70 ? Colors.green[200]! : 
                               percentage >= 50 ? Colors.orange[200]! : Colors.red[200]!,
                      ),
                    ),
                    child: Text(
                      _getPerformanceMessage(percentage),
                      style: TextStyle(
                        color: percentage >= 70 ? Colors.green[700] : 
                               percentage >= 50 ? Colors.orange[700] : Colors.red[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[300],
    );
  }

  Widget _buildSubmissionStatus() {
    if (!_isSubmitting && !_submissionSuccess && _submissionError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_isSubmitting) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                const Text("Submitting result...", style: TextStyle(fontWeight: FontWeight.w500)),
              ] else if (_submissionSuccess) ...[
                Icon(Icons.check_circle_rounded, color: Colors.green[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  "Result submitted successfully!",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ] else if (_submissionError != null) ...[
                Icon(Icons.error_rounded, color: Colors.red[600], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _submissionError!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _submitResult,
                  child: const Text("Retry"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsReview(List<Question> questions, Map<int, String> selectedAnswers) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_rounded, color: Colors.grey[700], size: 24),
              const SizedBox(width: 8),
              Text(
                "Question Review",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return _buildQuestionCard(questions[index], index, selectedAnswers[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index, String? userAnswer) {
    final correctAnswer = question.answer;
    final isCorrect = userAnswer != null &&
        userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isCorrect ? Colors.green[50]! : Colors.red[50]!,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green[500] : Colors.red[500],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_rounded : Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Question ${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Icon(Icons.star_rounded, color: Colors.amber[600], size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: isCorrect ? Colors.green[600] : Colors.red[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Your answer:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect ? Colors.green[200]! : Colors.red[200]!,
                          ),
                        ),
                        child: Text(
                          userAnswer ?? 'Not answered',
                          style: TextStyle(
                            color: isCorrect ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Correct answer:",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            correctAnswer,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.home_rounded, size: 24),
              label: const Text(
                "Back to Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[500],
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.green.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Get.offAllNamed(AppRoute.home),
            ),
          ),
         
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes}m ${remainingSeconds}s";
  }

  String _getGradeText(int percentage) {
    if (percentage >= 90) return "A+";
    if (percentage >= 80) return "A";
    if (percentage >= 70) return "B";
    if (percentage >= 60) return "C";
    if (percentage >= 50) return "D";
    return "F";
  }

  String _getPerformanceMessage(int percentage) {
    if (percentage >= 90) return "Outstanding Performance!";
    if (percentage >= 80) return "Excellent Work!";
    if (percentage >= 70) return "Great Job!";
    if (percentage >= 60) return "Good Effort!";
    if (percentage >= 50) return "Keep Improving!";
    return "Need More Practice";
  }
}