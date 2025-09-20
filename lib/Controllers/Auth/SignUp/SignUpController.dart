import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SignUpController {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:3000")); // emulator, change if real device
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final phone = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  /// Fetch available tracks
  Future<List<dynamic>> fetchTracks() async {
    try {
      final response = await _dio.get("/tracks");
      return response.data['tracks'] ?? [];
    } catch (e) {
      debugPrint("Error fetching tracks: $e");
      rethrow;
    }
  }

  /// Signup method
  Future<void> signup(List<int> selectedTrackIds, BuildContext context) async {
    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final body = {
      "name": name.text.trim(),
      "email": email.text.trim(),
      "password": password.text.trim(),
      "phone": phone.text.trim(),
      "selectedTrackIds": selectedTrackIds,
    };

    try {
      final response = await _dio.post("/signup", data: body);
      debugPrint("Signup Response: ${response.data}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${response.data['message']}")),
      );
    } on DioException catch (e) {
      debugPrint("Signup Error: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${e.response?.data['error']}")),
      );
    }
  }

  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    phone.dispose();
  }
}
