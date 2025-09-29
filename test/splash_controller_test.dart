import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Controllers/Splash/SplashController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

// Generate mocks using mockito
@GenerateMocks([SharedPreferences, SignInController, GetInterface])

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SplashController splashController;
  late FakeSignInController fakeSignInController;
  late String lastNavigation;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeSignInController = FakeSignInController();

    splashController = SplashController(signInControllerOverride: fakeSignInController)
      ..onNavigate = (route) {
        lastNavigation = route;
      };
  });

  test('navigates to home if token exists', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'valid-token');

    splashController.onReady();
    await Future.delayed(Duration(milliseconds: 50));

    expect(lastNavigation, AppRoute.home);
    expect(fakeSignInController.restoreUserCalled, true);
  });

  test('navigates to login if token missing', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    splashController.onReady();
    await Future.delayed(Duration(milliseconds: 50));

    expect(lastNavigation, AppRoute.login);
    expect(fakeSignInController.restoreUserCalled, false);
  });
}

class FakeSignInController extends SignInController {
  bool restoreUserCalled = false;

  @override
  Future<void> restoreUser() async {
    restoreUserCalled = true;
  }
}
