import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final score = args["score"] ?? 0;
    final total = args["total"] ?? 0;
    final percentage = args["percentage"] ?? 0;
    final autoSubmit = args["autoSubmit"] ?? false;

    final List<Question> questions = args["questions"] ?? [];
    final Map<int, String> selectedAnswers = args["selectedAnswers"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Result"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    autoSubmit ? "Time's Up!" : "Test Completed",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Score: $score/$total",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Percentage: $percentage%",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: percentage >= 70 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final userAnswer = selectedAnswers[index];
                final correctAnswer = q.answer;
                final isCorrect = userAnswer != null && userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${index + 1}: ${q.question}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your answer: ${userAnswer ?? 'Not answered'}",
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isCorrect)
                          Text(
                            "Correct answer: $correctAnswer",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoute.home),
                child: const Text("Back to Courses"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
