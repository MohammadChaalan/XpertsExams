import 'dart:convert';
import 'package:xpertexams/Models/TrackModel.dart';

class User {
  final int? id;
  final String? name;
  final String email;
  final String password;
  final List<Track> tracks;

  User({
    this.id,
    this.name,
    required this.email,
    required this.password,
    this.tracks = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      password: '', // don't send back from API
      tracks: (json['tracks'] as List?)?.map((e) => Track.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'password': password,
      };

  String toJson() => jsonEncode(toMap());
  
}

