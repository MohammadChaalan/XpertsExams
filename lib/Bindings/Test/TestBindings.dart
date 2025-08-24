import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Test/TestController.dart';

class TestBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestController>(() => TestController());
  }
  
}