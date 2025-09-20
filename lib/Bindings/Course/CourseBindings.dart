import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Course/CourseController.dart';

class Coursebindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseSelectionController>(() => CourseSelectionController());
  }
  
}