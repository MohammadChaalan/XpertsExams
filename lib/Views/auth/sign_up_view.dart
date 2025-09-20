import 'package:flutter/material.dart';
import 'package:xpertexams/Controllers/Auth/SignUp/SignUpController.dart';

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
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller.name,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: controller.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: controller.phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Password with toggle
            TextField(
              controller: controller.password,
              obscureText: !controller.isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: const OutlineInputBorder(),
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

            // Confirm Password
            TextField(
              controller: controller.confirmPassword,
              obscureText: !controller.isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: Icon(Icons.lock),
                border: const OutlineInputBorder(),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...tracks.map((track) {
                    return CheckboxListTile(
                      title: Text(track['name']),
                      subtitle: Text(track['description']),
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

            ElevatedButton(
              onPressed: () =>
                  controller.signup(selectedTrackIds, context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
