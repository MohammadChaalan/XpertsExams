import 'package:xpertexams/Models/CourseModel.dart';

class Track {
  final int id;
  final String name;
  final List<Course> courses;

  Track({
    required this.id,
    required this.name,
    this.courses = const [],
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      courses: (json['courses'] as List?)?.map((e) => Course.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'courses': courses.map((e) => e.toJson()).toList(),
      };
}
