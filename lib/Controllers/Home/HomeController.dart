// home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Core/Network/DioClient.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // Observable variables
  final RxInt selectedIndex = 0.obs;
  final RxBool isAnimationReady = false.obs;
  
  // Controllers
  late PageController pageController;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  
  // Data
  final List<TabData> tabs = [
    TabData(title: "Academy", icon: Icons.school, color: Colors.green),
    TabData(title: "Wallet", icon: Icons.account_balance_wallet, color: Colors.green),
    TabData(title: "Jobs", icon: Icons.work, color: Colors.green),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    pageController = PageController();
    
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    
    animationController.forward().then((_) {
      isAnimationReady.value = true;
    });
  }

  void onButtonTap(int index) {
    if (selectedIndex.value == index) return;
    
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  void onMenuTap() {
    Get.snackbar(
      "Menu",
      "Menu tapped",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  void onNotificationTap() {
    Get.snackbar(
      "Notifications", 
      "Notifications tapped",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  void onExploreSection(String section) {
    Get.snackbar(
      "Navigation",
      "Exploring $section section",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
  @override
  void onClose() {
    pageController.dispose();
    animationController.dispose();
    super.onClose();
  }
}

// Data class
class TabData {
  final String title;
  final IconData icon;
  final Color color;

  TabData({
    required this.title,
    required this.icon,
    required this.color,
  });
}