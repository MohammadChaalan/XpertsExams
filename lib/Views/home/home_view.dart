
// home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Home/HomeController.dart';
import 'package:xpertexams/Core/AppBar/HomeAppBar.dart';
import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
import 'package:xpertexams/Views/home/Academy_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Welcome back, User",
        subtitle: "Ready to continue your learning journey?",
        onMenuTap: controller.onMenuTap,
        onNotificationTap: controller.onNotificationTap,
      ),
      body: Obx(() => controller.isAnimationReady.value
          ? FadeTransition(
              opacity: controller.fadeAnimation,
              child: _buildMainContent(),
              
            )
          : _buildMainContent()
          ),

        bottomNavigationBar: CustomBottomBarPage(),




    );
    
  }
  

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildTabSection(),
        _buildPageView(),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Obx(() => Row(
          children: List.generate(controller.tabs.length, (index) {
            final isSelected = controller.selectedIndex.value == index;
            final tab = controller.tabs[index];
            
            return Expanded(
              child: _buildTabButton(index, tab, isSelected),
            );
          }),
        )),
      ),
    );
  }

  Widget _buildTabButton(int index, TabData tab, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onButtonTap(index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? tab.color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: tab.color.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.all(isSelected ? 6 : 4),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? tab.color 
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: 
                  isSelected ? 
                  
                  Icon(
                    tab.icon,
                    size: isSelected ? 18 : 18,
                    color: isSelected 
                        ? Colors.white 
                        : Colors.grey,
                  )
                  :
                  Row(
                    children: [
                      
                       Icon(
                    tab.icon,
                    size: isSelected ? 18 : 18,
                    color: isSelected 
                        ? Colors.white 
                        : Colors.grey,
                  ),
                  SizedBox(width: 10,),
                  Text(tab.title,)
                  
                    ],
                  ),
                  
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Text(
                      tab.title,
                      style: Get.textTheme.labelLarge?.copyWith(
                        color: tab.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          _buildPageContent(
            controller.tabs[0].title, 
            controller.tabs[0].icon, 
            controller.tabs[0].color
          ),
          _buildPageContent(
            controller.tabs[1].title, 
            controller.tabs[1].icon, 
            controller.tabs[1].color
          ),
          _buildPageContent(
            controller.tabs[2].title, 
            controller.tabs[2].icon, 
            controller.tabs[2].color
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(String title, IconData icon, Color color) {
  switch (title.toLowerCase()) {
    case "academy":
      return  AcademyView();
    case "wallet":
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: Text("Wallet Page")),
      );
    case "jobs":
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: Text("Jobs Page")),
      );
    default:
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: Text("Page not found")),
      );
  }
}

}

