import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Models/User/UserModel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SignInController signInController;

  setUp(() {
    SharedPreferences.setMockInitialValues({}); // reset mock storage
    signInController = SignInController();
  });

  group('Auth storage tests', () {
    test('saveAuthData stores token and user', () async {
      final userJson = {
        "id": 1,
        "name": "Test User",
        "email": "test@example.com",
        "tracks": []
      };

      await signInController.saveAuthData("fake-token", {"user": userJson});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("auth_token"), "fake-token");

      final storedUser = jsonDecode(prefs.getString("user_data")!);
      expect(storedUser["email"], "test@example.com");

      expect(signInController.user.value, isA<User>());
      expect(signInController.user.value!.email, "test@example.com");
    });

    test('restoreUser loads saved user', () async {
      final prefs = await SharedPreferences.getInstance();
      final userJson = {
        "id": 2,
        "name": "Restored User",
        "email": "restore@example.com",
        "tracks": []
      };
      await prefs.setString("auth_token", "restore-token");
      await prefs.setString("user_data", jsonEncode(userJson));

      await signInController.restoreUser();

      expect(signInController.user.value, isNotNull);
      expect(signInController.user.value!.email, "restore@example.com");
    });

    test('clearAuthData removes user', () async {
      final userJson = {
        "id": 3,
        "name": "Clear User",
        "email": "clear@example.com",
        "tracks": []
      };
      await signInController.saveAuthData("clear-token", {"user": userJson});

      await signInController.clearAuthData();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString("auth_token"), isNull);
      expect(prefs.getString("user_data"), isNull);
      expect(signInController.user.value, isNull);
    });
  });

  group('Helper functions', () {
    test('getCourses returns unique course names', () {
      signInController.user.value = User.fromJson({
        "id": 1,
        "email": "demo@test.com",
        "tracks": [
          {
            "name": "Track 1",
            "courses": [
              {"title": "Math", "exams": []},
              {"title": "Science", "exams": []}
            ]
          },
          {
            "name": "Track 2",
            "courses": [
              {"title": "Math", "exams": []}, // duplicate
              {"title": "English", "exams": []}
            ]
          }
        ]
      });

      final courses = signInController.getCourses();

      expect(courses, containsAll(["Math", "Science", "English"]));
      expect(courses.length, 3);
    });

    test('isAuthenticated returns true when user is set', () {
      expect(signInController.isAuthenticated, false);

      signInController.user.value = User(id: 99, email: "auth@test.com",password: "securePassword123",);
      expect(signInController.isAuthenticated, true);
    });
  });
}
