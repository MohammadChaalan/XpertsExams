import 'package:get/get.dart';
import 'package:xpertexams/Bindings/Auth/SignInBindings.dart';
import 'package:xpertexams/Bindings/Auth/SignUpBindings.dart';
import 'package:xpertexams/Bindings/Home/HomeBindings.dart';
import 'package:xpertexams/Bindings/Splash/SplashBindings.dart';
import 'package:xpertexams/Models/TrackModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/Demo/home_offline_view.dart';
import 'package:xpertexams/Views/Splash/Splash_view.dart';
import 'package:xpertexams/Views/auth/sign_in_view.dart';
import 'package:xpertexams/Views/auth/sign_up_view.dart';
import 'package:xpertexams/Views/home/home_view.dart';
import 'package:xpertexams/Views/notifications/notifications_view.dart';
import 'package:xpertexams/Views/test/test_track_view.dart';
import 'package:xpertexams/Views/test/test_view.dart';
import 'package:xpertexams/Views/tracks/track_view.dart';
import 'package:xpertexams/Views/video/video_view.dart';

class Apppage {

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoute.home,
      page: () => HomeView(),
      binding: HomeBindings(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoute.splash,
      page: () => SplashScreen(),
      binding: SplashBindings(),
    ),
    GetPage(
      name: AppRoute.login,
      page: () => SignInView(),
      binding: SignInBindings(),
    ),
    GetPage(
      name: AppRoute.register,
      page: () => SignUpView(),
      binding: SignUpBindings(),
    ),
    GetPage(name: AppRoute.demoOffline, 
    page: () => HomeOfflineView()),
    GetPage(
  name: AppRoute.tracksContent,
  page: () => const TracksContentView(),
),
 GetPage(
  name: AppRoute.notifications,
  page: () => const NotificationsView(),
),
// GetPage(
//   name: AppRoute.videoContent,
//           page: () => TrackAllVideosPage(),
// ),
GetPage(
  name: AppRoute.track,
      page: () => TrackCoursesView(),
    ),
    GetPage(
      name: AppRoute.test,
      page: () => TestView(),
      // binding: TestBindings(),
    ),
    
  ];
}