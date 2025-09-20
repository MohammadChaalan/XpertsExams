import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Splash/SplashController.dart';

class SplashBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
  
}