import 'QuestionModel.dart';

class Exam {
  final int id;
  final String title;
  final List<Question> questions;

  Exam({
    required this.id,
    required this.title,
    this.questions = const [],
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      questions: (json['questions'] as List?)?.map((e) => Question.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}
