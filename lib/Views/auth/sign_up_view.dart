import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignUp/SignUpController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final controller = SignUpController();
  List<dynamic> tracks = [];
  List<int> selectedTrackIds = [];

  @override
  void initState() {
    super.initState();
    controller.fetchTracks().then((data) {
      setState(() {
        tracks = data;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.person_add_alt_1,
                  size: 100,
                  color: Colors.white,
                ),
                const Text(
                  'Create Account',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  'Sign up to get started',
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
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.green[400])),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Colors.green[400])),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon:
                                  Icon(Icons.phone, color: Colors.green[400])),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.password,
                          obscureText: !controller.isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.green[400]),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  controller.isPasswordVisible =
                                      !controller.isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: controller.confirmPassword,
                          obscureText: !controller.isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.green[400]),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  controller.isConfirmPasswordVisible =
                                      !controller.isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Track selection
                        if (tracks.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Select Track(s):",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...tracks.map((track) {
                                return CheckboxListTile(
                                  title: Text(track['name']),
                                  subtitle: Text(track['description']),
                                  activeColor: Colors.green[400],
                                  value: selectedTrackIds.contains(track['id']),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedTrackIds.add(track['id']);
                                      } else {
                                        selectedTrackIds.remove(track['id']);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ],
                          ),

                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[300],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                controller.signup(selectedTrackIds, context),
                            child: const Text('Sign Up'),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green[300],
                              side: BorderSide(
                                  color: Colors.green[300]!, width: 1.5),
                            ),
                            onPressed: () {
                              Get.toNamed(AppRoute.login);
                            },
                            child:
                                const Text('Already have an account? Sign In'),
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
