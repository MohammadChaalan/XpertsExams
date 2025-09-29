import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Core/common_colors/color_extension.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                 Icon(
                  Icons.account_circle,
                  size: 100,
                  color: TColor.secondary,
                ),
                 Text(
                  'Welcome Back',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: TColor.secondary),
                ),
                 Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 15, color: TColor.secondary),
                ),
                const SizedBox(height: 20),
                Card(
                  color: TColor.secondary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller.email,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: TColor.primary)),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          obscureText: true,
                          controller: controller.password,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: TColor.primary)),
                        ),
                        const SizedBox(height: 20),
                        Obx(() => controller.isChecked.value
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.green[300]!, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.green[100],
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: controller.isChecked.value,
                                      onChanged: controller.toggleCheck,
                                    ),
                                    Text('I agree to ',
                                        style: TextStyle(
                                            color: Colors.green[300])),
                                    InkWell(
                                      onTap: () {},
                                      child: const Text('Terms and Conditions',
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline)),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.orange, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.orange[100],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: controller.isChecked.value,
                                          onChanged: controller.toggleCheck,
                                        ),
                                        Text('I agree to ',
                                            style: TextStyle(
                                                color: Colors.orange[300])),
                                        InkWell(
                                          onTap: () {},
                                          child: const Text(
                                              'Terms and Conditions',
                                              style: TextStyle(
                                                  decoration: TextDecoration
                                                      .underline)),
                                        ),
                                      ],
                                    ),
                                    const Row(
                                      children: [
                                        Icon(Icons.camera_alt_outlined,
                                            color: Colors.red),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            "This app takes photos during tests to prevent cheating",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColor.button,
                              foregroundColor: TColor.textButton,
                            ),
                            onPressed: () {
                              // Handle sign in logic
                              controller.login();
                            },
                            child: const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColor.button2,
                              foregroundColor: TColor.textButton2,
                              side: BorderSide(
                                  color: Colors.green[300]!, width: 1.5),
                            ),
                            onPressed: () {
                              // Handle sign in logic
                              Get.toNamed(AppRoute.register);
                            },
                            child: const Text('Create New Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
