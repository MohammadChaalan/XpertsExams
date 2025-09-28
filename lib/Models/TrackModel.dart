import 'package:xpertexams/Models/CourseModel.dart';

class Track {
  final int? id;
  final String name;
  final List<Course> courses;

  Track({
    this.id,
    required this.name,
    this.courses = const [],
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
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
