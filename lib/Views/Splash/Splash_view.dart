import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Splash/SplashController.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SplashController
    Get.put(SplashController());

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'XpertExams',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
          ],
        ),
      ),
    );
  }
}
