import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/User/UserModel.dart';

class SignUpController extends GetxController {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController phone = TextEditingController();

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  Future<void> register() async {
    if (password.text != confirmPassword.text) {
      Get.snackbar("Error", "Passwords do not match",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      User user = User(email: email.text, password: password.text, name: name.text);
      var response =
          await DioClient().getInstance().post("/signup", data: user.toJson());

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Registration completed!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Registration failed",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Registration error: $e");
      Get.snackbar("Error", "Unexpected error occurred",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
