import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SplashController extends GetxController {
  static const String _tokenKey = 'auth_token';

  @override
  void onReady() {
    super.onReady();
    Future.microtask(() => _checkToken());
  }

  Future<void> _checkToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null && token.isNotEmpty) {
        print("✅ Token found: $token, navigating to home");

        // Optionally restore user in memory if you keep it globally
        final signInController = Get.find<SignInController>();
        // user remains null until login

        signInController.restoreUser();
        Get.offAllNamed(AppRoute.home);
      } else {
        print("ℹ️ No token found, navigating to login");
        Get.offAllNamed(AppRoute.login);
      }
    } catch (e) {
      print("❌ Error checking token: $e");
      Get.offAllNamed(AppRoute.login);
    }
  }
}
