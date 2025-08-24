import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/CourseModel.dart';


class CourseSelectionController extends GetxController {
  final SignInController signInController = Get.find();

  var courses = <Course>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  void loadCourses() {
    courses.value = signInController.user.value!.tracks!
        .expand((track) => track.courses!)
        .toList();
  }
}
