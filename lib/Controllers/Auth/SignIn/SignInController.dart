import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/User/UserModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SignInController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  var isChecked = false.obs;
  void toggleCheck(bool? value) {
    isChecked.value = value ?? false;
  }

  void Login() async {
    try {
      User user = User(email: email.text, password: password.text);

      String requestBody = user.toJson();
      if (isChecked == false) {
        Get.snackbar("Error", "agree to terms and conditions",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        var response = await DioClient()
            .getInstance()
            .post('/api/login', data: requestBody);

        if (response.statusCode == 200) {
          print("Login Success");
          // Get.toNamed(AppRoute.home);
        } else {
          print("login failed");
        }
      }
    } catch (e) {
      print("login failed: $e");
      Get.snackbar("Error", "Failed to login",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
