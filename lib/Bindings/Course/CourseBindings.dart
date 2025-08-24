import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignUp/SignUpController.dart';
import 'package:xpertexams/Controllers/Course/CourseController.dart';
import 'package:xpertexams/Controllers/Home/HomeController.dart';

class Coursebindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseSelectionController>(() => CourseSelectionController());
  }
  
}