import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';
import 'package:xpertexams/Models/QuestionModel.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Models/User/UserModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class SignInController extends GetxController {
  // Form controllers
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  
  // Observable variables
  final RxBool isChecked = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<User> user = Rxn<User>();

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  @override
  void onInit() {
    super.onInit();
    restoreUser();
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  void toggleCheck(bool? value) {
    isChecked.value = value ?? false;
  }

  /// Restore user from SharedPreferences
  Future<void> restoreUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token != null && userData != null && userData.isNotEmpty) {
        final data = jsonDecode(userData) as Map<String, dynamic>;
        user.value = User.fromJson(_normalizeUserData(data));
        print("✅ User restored: ${user.value!.email}, Tracks: ${user.value!.tracks?.length ?? 0}");
      } else {
        print("⚠️ No saved user data found");
      }
    } catch (e) {
      print("❌ Error restoring user: $e");
      await clearAuthData(); // Clear corrupted data
    }
  }

  /// Save authentication data
  Future<void> saveAuthData(String token, Map<String, dynamic> responseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Extract user data from response
      final userData = Map<String, dynamic>.from(responseData['user'] ?? {});
      final normalizedUser = _normalizeUserData(userData);

      // Save to SharedPreferences
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(normalizedUser));

      // Update in-memory user
      user.value = User.fromJson(normalizedUser);

      print("✅ Auth data saved - User: ${user.value!.email}, Tracks: ${normalizedUser['tracks']?.length ?? 0}");
    } catch (e) {
      print("❌ Error saving auth data: $e");
      rethrow;
    }
  }

  /// Clear authentication data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      user.value = null;
      print("✅ Auth data cleared");
    } catch (e) {
      print("❌ Error clearing auth data: $e");
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await clearAuthData();
      
      // Clear form data
      email.clear();
      password.clear();
      isChecked.value = false;
      
      Get.offAllNamed(AppRoute.login);
    } catch (e) {
      print("❌ Error during logout: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Login method
  Future<void> login() async {
    // Validate inputs
    if (email.text.trim().isEmpty || password.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both email and password",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!isChecked.value) {
      Get.snackbar(
        "Error",
        "Please agree to terms and conditions",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Create user object for login
      final loginUser = User(email: email.text.trim(), password: password.text);
      
      // Make API call
      final response = await DioClient().getInstance().post(
        "/login", 
        data: loginUser.toJson(),
      );

      if (response.statusCode == 200) {
        // Parse response data
        final responseData = response.data is String 
          ? jsonDecode(response.data) as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data);

        // Extract token
        final token = responseData['token'] ?? 
                     responseData['access_token'] ?? 
                     responseData['authToken'];
        
        if (token == null || token.toString().isEmpty) {
          throw Exception("No authentication token received");
        }

        // Save authentication data
        await saveAuthData(token.toString(), responseData);

        print("✅ Login successful for: ${user.value!.email}");
        
        // Navigate to home
        Get.offAllNamed(AppRoute.home, arguments: responseData);
        
        // Show success message
        Get.snackbar(
          "Success",
          "Welcome back, ${user.value!.email}!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
      } else {
        throw Exception("Login failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Login error: $e");
      
      String errorMessage = "Login failed";
      if (e.toString().contains("401")) {
        errorMessage = "Invalid email or password";
      } else if (e.toString().contains("network")) {
        errorMessage = "Network error. Please check your connection";
      }
      
      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Normalize user data to handle null values and ensure proper structure
  Map<String, dynamic> _normalizeUserData(Map<String, dynamic> userData) {
    try {
      final normalized = Map<String, dynamic>.from(userData);
      
      // Ensure tracks is a proper list
      normalized['tracks'] = (normalized['tracks'] as List? ?? [])
          .map((track) {
            final t = Map<String, dynamic>.from(track ?? {});
            
            // Ensure courses is a proper list
            t['courses'] = (t['courses'] as List? ?? [])
                .map((course) {
                  final c = Map<String, dynamic>.from(course ?? {});
                  
                  // Ensure exams is a proper list
                  c['exams'] = (c['exams'] as List? ?? [])
                      .map((exam) {
                        final e = Map<String, dynamic>.from(exam ?? {});
                        
                        // Ensure questions is a proper list
                        e['questions'] = (e['questions'] as List? ?? [])
                            .map((question) => Map<String, dynamic>.from(question ?? {}))
                            .toList();
                        
                        return e;
                      })
                      .toList();
                  
                  return c;
                })
                .toList();
            
            return t;
          })
          .toList();

      return normalized;
    } catch (e) {
      print("❌ Error normalizing user data: $e");
      return {
        ...userData,
        'tracks': <Map<String, dynamic>>[],
      };
    }
  }

  /// Get all available courses
  List<String> getCourses() {
    try {
      final currentUser = user.value;
      if (currentUser == null) {
        print("⚠️ getCourses(): No user loaded");
        return [];
      }

      final courseNames = <String>{};
      
      for (final track in currentUser.tracks ?? []) {
        for (final course in track.courses ?? []) {
          final title = course.title?.toString().trim();
          if (title != null && title.isNotEmpty) {
            courseNames.add(title);
          }
        }
      }
      
      final sortedCourses = courseNames.toList()..sort();
      print("📚 Found ${sortedCourses.length} courses: ${sortedCourses.join(', ')}");
      
      return sortedCourses;
    } catch (e) {
      print("❌ Error getting courses: $e");
      return [];
    }
  }

  /// Get questions for a specific course
  List<Question> getQuestionsByCourse(String courseTitle) {
    try {
      final currentUser = user.value;
      final questions = <Question>[];

      if (currentUser == null) {
        print("⚠️ getQuestionsByCourse(): No user loaded");
        return questions;
      }

      if (courseTitle.trim().isEmpty) {
        print("⚠️ getQuestionsByCourse(): Empty course title");
        return questions;
      }

      final targetCourse = courseTitle.toLowerCase().trim();

      for (final track in currentUser.tracks ?? []) {
        for (final course in track.courses ?? []) {
          final courseName = (course.title ?? '').toLowerCase().trim();
          
          if (courseName == targetCourse) {
            for (final exam in course.exams ?? []) {
              for (final questionData in exam.questions ?? []) {
                try {
                  // If already a Question object
                  if (questionData is Question) {
                    questions.add(questionData);
                    continue;
                  }

                  // Parse from Map
                  final questionMap = Map<String, dynamic>.from(questionData ?? {});
                  
                  final id = int.tryParse(questionMap['id']?.toString() ?? '') ?? 
                           questionMap.hashCode;
                  
                  final questionText = (questionMap['question'] ??
                                     questionMap['title'] ??
                                     questionMap['text'] ??
                                     'Question text not available').toString();

                  final rawOptions = questionMap['options'] ?? 
                                   questionMap['choices'] ?? 
                                   [];
                  
                  final options = <String>[];
                  if (rawOptions is List) {
                    for (final option in rawOptions) {
                      final optionText = option.toString().trim();
                      if (optionText.isNotEmpty) {
                        options.add(optionText);
                      }
                    }
                  }

                  final correctAnswer = (questionMap['answer'] ??
                                      questionMap['correct'] ??
                                      questionMap['correct_answer'] ??
                                      '').toString().trim();

                  // Only add question if it has valid data
                  if (questionText.isNotEmpty && 
                      options.isNotEmpty && 
                      correctAnswer.isNotEmpty) {
                    questions.add(Question(
                      id: id,
                      question: questionText,
                      options: options,
                      answer: correctAnswer,
                    ));
                  }
                } catch (questionError) {
                  print("❌ Error parsing individual question: $questionError");
                  continue;
                }
              }
            }
          }
        }
      }

      print("📝 getQuestionsByCourse('$courseTitle'): Found ${questions.length} questions");
      return questions;
    } catch (e) {
      print("❌ Error getting questions for course '$courseTitle': $e");
      return [];
    }
  }

  /// Get saved authentication token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print("❌ Error getting auth token: $e");
      return null;
    }
  }
/// Get all available tracks for the current user
List<Track> getTracks() {
  try {
    final currentUser = user.value;
    if (currentUser == null) {
      print("⚠️ getTracks(): No user loaded");
      return [];
    }

    final userTracks = <Track>[];
    
    for (final trackData in currentUser.tracks ?? []) {
      try {
        // Convert track data to Track object
        final trackMap = trackData.toJson();
        final track = Track.fromJson(trackMap);
        userTracks.add(track);
      } catch (trackError) {
        print("❌ Error parsing track: $trackError");
        continue;
      }
    }
    
    print("🎯 Found ${userTracks.length} tracks for user: ${userTracks.map((t) => t.name).join(', ')}");
    
    return userTracks;
  } catch (e) {
    print("❌ Error getting tracks: $e");
    return [];
  }
}

/// Get track statistics
Map<String, int> getTrackStats() {
  try {
    final tracks = getTracks();
    int totalCourses = 0;
    int totalVideos = 0;
    int totalExams = 0;
    
    for (final track in tracks) {
      totalCourses += track.courses.length;
      for (final course in track.courses) {
        totalVideos += course.video.length;
        totalExams += course.exams?.length ?? 0;
      }
    }
    
    return {
      'tracks': tracks.length,
      'courses': totalCourses,
      'videos': totalVideos,
      'exams': totalExams,
    };
  } catch (e) {
    print("❌ Error getting track stats: $e");
    return {
      'tracks': 0,
      'courses': 0,
      'videos': 0,
      'exams': 0,
    };
  }
}

/// Get a specific track by name
Track? getTrackByName(String trackName) {
  try {
    final tracks = getTracks();
    for (final track in tracks) {
      if (track.name.toLowerCase().trim() == trackName.toLowerCase().trim()) {
        return track;
      }
    }
    return null;
  } catch (e) {
    print("❌ Error getting track by name '$trackName': $e");
    return null;
  }
}
  /// Check if user is authenticated
  bool get isAuthenticated => user.value != null;

  /// Get current user email
  String get currentUserEmail => user.value?.email ?? '';
}