import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/User/UserModel.dart';

class SignUpController extends GetxController {
  // Your controller logic here
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController ConfirmPassword = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController track = TextEditingController();

  void register() async {
    try {
      User user = User(
        email: email.text,
        password: password.text,
      );

      String requestBody = user.toJson();
      print("Request Body : ${requestBody}");

      if (ConfirmPassword.text != password.text) {
        print("diff password");
         Get.snackbar("Error", "confirm password failed",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else
      {
        var response = await DioClient()
          .getInstance()
          .post("/api/register", data: requestBody);

      if (response.statusCode == 200) {
        print("Registration Successful : ${response.data}");
        Get.snackbar("Success", "Registration completed!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print(
            "Registration failed: ${response.statusCode} -> ${response.data}");
        Get.snackbar("Error", "Registration failed",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      }
    } catch (e) {
      print("$e");
      Get.snackbar("Error", "Unexpected error occurred",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String? validateConfirmPassword() {
    if (ConfirmPassword.text != password.text) {
      return "Passwords do not match";
    }
    return null;
  }

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }
}
