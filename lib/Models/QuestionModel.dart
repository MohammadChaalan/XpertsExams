class Question {
  final int id;
  final String question;
  final List<String> options;
  final String answer;

  Question({
    required this.id,
    required this.question,
    this.options = const [],
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'answer': answer,
      };
}
