import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SplashController extends GetxController {
  static const String _tokenKey = 'auth_token';

  /// Optional injected controller for testing
  final SignInController? signInControllerOverride;

  /// Optional navigation callback for tests
  void Function(String routeName)? onNavigate;

  SplashController({this.signInControllerOverride});

  @override
  void onReady() {
    super.onReady();
    Future.microtask(() => checkToken());
  }

  /// Checks for token and navigates accordingly
  Future<void> checkToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null && token.isNotEmpty) {
        print("✅ Token found: $token, navigating to home");

        final signInController = signInControllerOverride ?? Get.find<SignInController>();
        await signInController.restoreUser();

        if (onNavigate != null) {
          onNavigate!(AppRoute.home);
        } else {
          Get.offAllNamed(AppRoute.home);
        }
      } else {
        print("ℹ️ No token found, navigating to login");
        if (onNavigate != null) {
          onNavigate!(AppRoute.login);
        } else {
          Get.offAllNamed(AppRoute.login);
        }
      }
    } catch (e) {
      print("❌ Error checking token: $e");
      if (onNavigate != null) {
        onNavigate!(AppRoute.login);
      } else {
        Get.offAllNamed(AppRoute.login);
      }
    }
  }
}
