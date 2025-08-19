import 'package:get/get.dart';
import 'package:xpertexams/Bindings/SignIn/SignInBindings.dart';
import 'package:xpertexams/Bindings/SignUp/SignUpBindings.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/auth/sign_in_view.dart';
import 'package:xpertexams/Views/auth/sign_up_view.dart';

class Apppage {

  static final List<GetPage> pages = [
    // GetPage(
    //   name: AppRoute.home,
    //   page: () => HomeView(),
    //   binding: HomeBindings(),
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