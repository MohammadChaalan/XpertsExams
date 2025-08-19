import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Bindings/SignIn/SignInBindings.dart';
import 'package:xpertexams/Bindings/SignUp/SignUpBindings.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/auth/sign_up_view.dart';
import 'package:xpertexams/views/auth/sign_in_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Xperts Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.login,
      getPages: [
        GetPage(
          name: AppRoute.login,
          page: () => const SignInView(),
          binding: SignInBindings(),
        ),
        GetPage(
          name: AppRoute.register,
          page: () => SignUpView(),
          binding: SignUpBindings(),
        ),
      ],

       );
  }
}

