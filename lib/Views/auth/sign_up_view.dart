import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignUp/SignUpController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SignUpView extends GetView<SignUpController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
                const Text(
                  'XpertTest',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  'Sign Up to your account',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller.name,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.person_pin,
                                color: Colors.green[400]),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.phone,
                          decoration: InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon:
                                  Icon(Icons.phone, color: Colors.green[400])),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.email,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Colors.green[400])),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        Obx(() => TextField(
                              controller: controller.password,
                              obscureText: controller.isPasswordHidden.value,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Colors.green[400]),
                                suffixIcon: IconButton(
                                  icon: Icon(controller.isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                ),
                              ),
                            )),
                        const SizedBox(height: 20),
                        Obx(() => TextField(
                              controller: controller.ConfirmPassword,
                              obscureText:
                                  controller.isConfirmPasswordHidden.value,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Colors.green[400]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      controller.isConfirmPasswordHidden.value
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                  onPressed: controller
                                      .toggleConfirmPasswordVisibility,
                                ),
                              ),
                            )),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[300],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              controller.register();
                            },
                            child: const Text('Sign Up'),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green[400],
                            ),
                            onPressed: () {
                              // Handle sign in logic
                              Get.toNamed(AppRoute.login);
                            },
                            child: const Text('Go To Sign In'),
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
