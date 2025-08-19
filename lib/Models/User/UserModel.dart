import 'dart:convert';

class User {

  final String? name;
  final String email;
  final String password;
  final String? phone;
  final List<String>? track;

  User({
    this.name,
    required this.email,
    required this.password,
    this.phone,
    this.track,
  });

  Map<String , dynamic> toMap(){
    return {
      'name' : name,
      'email' : email,
      'password' : password,
      'phone' : phone,

    };
  }
  String toJson() => jsonEncode(toMap());
}