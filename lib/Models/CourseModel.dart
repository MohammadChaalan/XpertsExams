import 'VideoModel.dart';
import 'ExamModel.dart';

class Course {
  final int id;
  final String title;
  final String? description; // <-- add this
  final List<Video> video;
  final List<Exam> exams;

  Course({
    required this.id,
    required this.title,
    this.description,
    required this.video,
    required this.exams,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'], // <-- parse description
      video: (json['videos'] as List? ?? [])
    .map((v) => Video.fromJson(v))
    .toList(),

      exams: (json['exams'] as List? ?? [])
          .map((e) => Exam.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'videos': video.map((v) => v.toJson()).toList(),
        'exams': exams.map((e) => e.toJson()).toList(),
      };
}
