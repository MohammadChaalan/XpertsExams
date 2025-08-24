import 'package:get/get.dart';
import 'package:xpertexams/Bindings/Auth/SignInBindings.dart';
import 'package:xpertexams/Bindings/Auth/SignUpBindings.dart';
import 'package:xpertexams/Bindings/Course/CourseBindings.dart';
import 'package:xpertexams/Bindings/Home/HomeBindings.dart';
import 'package:xpertexams/Bindings/Test/TestBindings.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/auth/sign_in_view.dart';
import 'package:xpertexams/Views/auth/sign_up_view.dart';
import 'package:xpertexams/Views/home/home_view.dart';
import 'package:xpertexams/Views/test/TestCourseSelection_view.dart';
import 'package:xpertexams/Views/test/test_view.dart';

class Apppage {

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoute.home,
      page: () => HomeView(),
      binding: HomeBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
     GetPage(
      name: AppRoute.test,
      page: () => TestView(),
      binding: TestBindings(),
    ),
    // GetPage(
    //   name: AppRoute.courseSelection,
    //   page: () => CourseSelectionPage(),
    //   binding: Coursebindings(),
    // ),
    GetPage(
      name: AppRoute.login,
      page: () => SignInView(),
      binding: SignInBindings(),
    ),
    GetPage(
      name: AppRoute.register,
      page: () => SignUpView(),
      binding: SignUpBindings(),
    ),
  ];
}