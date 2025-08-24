import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Test/TestController.dart';

class TestView extends GetView<TestController> {
  const TestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test")),
      body: Obx(() {
        if (controller.questions.isEmpty) {
          return const Center(child: Text("No questions available"));
        }
      
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            final q = controller.questions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q${index + 1}: ${q.question}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...q.options.map(
                      (option) => RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: controller.selectedAnswers[index] ?? "",
                        onChanged: (value) {
                          controller.selectAnswer(index, value!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: controller.submit,
          child: const Text("Submit"),
        ),
      ),
    );
  }
}
