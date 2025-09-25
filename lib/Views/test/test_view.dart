import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Test/TestController.dart';

class TestView extends StatefulWidget {
  const TestView({super.key });

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  TestController? controller;
  bool isInitialized = false;

  Timer? _timer;
  int _remainingSeconds = 10; // 10 seconds example

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() async {
  if (Get.isRegistered<TestController>()) {
    controller = Get.find<TestController>();
  } else {
    controller = Get.put(TestController());
  }

  String? courseTitle;

  // 1. Try from URL parameters (if using dynamic routes like /test/:course)
  if (Get.parameters['course'] != null) {
    courseTitle = Get.parameters['course'];
  }
  // 2. Try from arguments
  else if (Get.arguments != null) {
    final args = Get.arguments;
    if (args is String) {
      courseTitle = args;
    } else if (args is Map<String, dynamic> && args.containsKey("course")) {
      courseTitle = args["course"] as String?;
    }
  }

  if (courseTitle != null && controller != null) {
    await Future.delayed(const Duration(milliseconds: 100));
    controller!.loadQuestions(courseTitle);
  }

  setState(() {
    isInitialized = true;
  });

  _startTimer();
}


  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _onTimeUp();
      }
    });
  }

void _onTimeUp() {
  if (controller != null) {
    controller!.submitTest(); // Auto-submit test and go to ResultView
  }
}



  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Timer
          Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.black54),
                const SizedBox(width: 8),
                Text(_formatTime(_remainingSeconds),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Questions
          Expanded(
            child: GetBuilder<TestController>(
              init: controller,
              builder: (ctrl) => Obx(() {
                if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (ctrl.questions.isEmpty) return const Center(child: Text("No questions available"));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.questions.length,
                  itemBuilder: (context, index) {
                    final question = ctrl.questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Q${index + 1}: ${question.question}"),
                            ...question.options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final option = entry.value;
                              return RadioListTile<String>(
                                title: Text("${String.fromCharCode(65 + optionIndex)}. $option"),
                                value: option,
                                groupValue: ctrl.selectedAnswers[index],
                                onChanged: (value) {
                                  if (value != null) ctrl.selectAnswer(index, value);
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: controller!.questions.isEmpty ? null : () => controller!.submitTest(),
                child: Text(
                    "Submit Test (${controller!.selectedAnswers.length}/${controller!.questions.length})" ,
                    style: const TextStyle(color: Colors.white),
                    ),
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
