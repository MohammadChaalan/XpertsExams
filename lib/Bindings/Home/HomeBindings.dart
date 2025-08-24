import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignUp/SignUpController.dart';
import 'package:xpertexams/Controllers/Home/HomeController.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
  
}