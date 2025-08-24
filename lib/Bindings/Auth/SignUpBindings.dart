import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignUp/SignUpController.dart';

class SignUpBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
  
}