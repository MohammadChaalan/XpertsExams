import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/User/UserModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SignInController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  var isChecked = false.obs;

  // User data after login
  var user = Rxn<User>();

  void toggleCheck(bool? value) => isChecked.value = value ?? false;

  Future<void> login() async {
    if (!isChecked.value) {
      Get.snackbar(
        "Error",
        "Please agree to terms and conditions",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      User u = User(email: email.text, password: password.text);
      var response =
          await DioClient().getInstance().post("/login", data: u.toJson());

      if (response.statusCode == 200) {
        Map<String, dynamic> data;

        if (response.data is String) {
          data = jsonDecode(response.data);
        } else {
          data = Map<String, dynamic>.from(response.data);
        }

        // Normalize function to replace null lists with []
        Map<String, dynamic> normalizeUser(Map<String, dynamic> userJson) {
          userJson['tracks'] = (userJson['tracks'] as List? ?? [])
              .map((t) {
                t = Map<String, dynamic>.from(t);
                t['courses'] = (t['courses'] as List? ?? [])
                    .map((c) {
                      c = Map<String, dynamic>.from(c);
                      c['exams'] = (c['exams'] as List? ?? [])
                          .map((e) {
                            e = Map<String, dynamic>.from(e);
                            e['questions'] = (e['questions'] as List? ?? [])
                                .map((q) => Map<String, dynamic>.from(q))
                                .toList();
                            return e;
                          })
                          .toList();
                      return c;
                    })
                    .toList();
                return t;
              })
              .toList();
          return userJson;
        }

        final safeUserJson =
            normalizeUser(Map<String, dynamic>.from(data['user'] ?? {}));
        user.value = User.fromJson(safeUserJson);

        print(
            "✅ User Data: ${user.value!.email} , Tracks: ${user.value!.tracks?.length ?? 0}");
        getAllQuestions();

        Get.offAllNamed(AppRoute.home, arguments: data);
      } else {
        Get.snackbar(
          "Error",
          "Login Failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stack) {
      print("❌ Login error: $e");
      print(stack);
      Get.snackbar(
        "Error",
        "Unexpected error occurred",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void getAllQuestions() {
    if (user.value == null) return;

    for (var track in user.value!.tracks ?? []) {
      for (var course in track.courses ?? []) {
        for (var exam in course.exams ?? []) {
          print(
              "📘 Course: ${course.title}, 📝 Exam: ${exam.title}, ❓ Questions: ${exam.questions?.length ?? 0}");
        }
      }
    }
  }
}
