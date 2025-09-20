import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Bindings/Auth/SignInBindings.dart';
import 'package:xpertexams/Bindings/Auth/SignUpBindings.dart';
import 'package:xpertexams/Bindings/Course/CourseBindings.dart';
import 'package:xpertexams/Bindings/Home/HomeBindings.dart';
import 'package:xpertexams/Bindings/Splash/SplashBindings.dart';
import 'package:xpertexams/Bindings/Test/TestBindings.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Controllers/Test/TestController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/Splash/Splash_view.dart';
import 'package:xpertexams/Views/auth/sign_up_view.dart';
import 'package:xpertexams/Views/home/home_view.dart';
import 'package:xpertexams/Views/test/TestCourseSelection_view.dart';
import 'package:xpertexams/Views/test/result_view.dart';
import 'package:xpertexams/Views/test/test_track_view.dart';
import 'package:xpertexams/Views/test/test_view.dart';
import 'package:xpertexams/Views/tracks/track_view.dart';
import 'package:xpertexams/views/auth/sign_in_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(SignInController());
  Get.put(TestController());

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
      initialRoute: AppRoute.splash,
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
        GetPage(
          name: AppRoute.home,
          page: () => const HomeView(),
          binding: HomeBindings(),
        ),
        GetPage(
          name: AppRoute.test,
          page: () => const TestView(),
          binding: TestBindings(),
        ),
       GetPage(
  name: AppRoute.courseSelection,
  page: () {
    final args = Get.arguments as Map<String, dynamic>;
    return CourseSelectionView(
      exams: args["exams"],
      track: args["track"],
    );
  },
  binding: Coursebindings(),
),
        GetPage(
          name: AppRoute.splash,
          page: () => SplashScreen(),
          binding: SplashBindings(),
        ),
        GetPage(
          name: AppRoute.result,
          page: () => const ResultView(),
        ),
        GetPage(
          name: AppRoute.track,
          page: () => TrackCoursesView(),
        ),
        GetPage(
          name: AppRoute.tracksContent,
          page: () => const TracksContentView(),
        ),
      ],
    );
  }
}
