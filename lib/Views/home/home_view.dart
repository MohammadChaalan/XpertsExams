import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Core/AppBar/HomeAppBar.dart';
import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/home/Academy_view.dart';
import 'package:xpertexams/Views/home/Jobs_view.dart';
import 'package:xpertexams/Views/home/Wallet_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late PageController _pageController;
  int _selectedIndex = 0;

  final SignInController signInController = Get.find<SignInController>();

  final List<TabData> tabs = const [
    TabData(title: "Academy", icon: Icons.school, color: Colors.green),
    TabData(
        title: "Wallet", icon: Icons.account_balance_wallet, color: Colors.green),
    TabData(title: "Jobs", icon: Icons.work, color: Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onButtonTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showUserMenu() {
    final user = signInController.user.value; // <- your logged-in user
    final name = user?.name ?? "Guest User";
    final email = user?.email ?? "guest@example.com";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);

                  // Call logout logic from controller
                  await signInController.logout();

                  Get.snackbar(
                    "Logged Out",
                    "You have successfully logged out",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );

                  // Navigate back to login screen
                  Get.offAllNamed(AppRoute.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "Welcome back, ${signInController.user.value?.name ?? 'User'}",
        subtitle: "Ready to continue your learning journey?",
        onMenuTap: _showUserMenu,
        onNotificationTap: () {
          print("Notification tapped");
        },
      ),
      body: Column(
        children: [
          _buildTabSection(),
          Expanded(
            child: PageView(
              key: const PageStorageKey('home_pageview'),
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children:  [
                AcademyView(),
                WalletView(),
               JobsView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBarPage(initialIndex: 0,),
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
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: TextButton(
              onPressed: () => _onButtonTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab.icon, color: isSelected ? tab.color : Colors.grey),
                  const SizedBox(height: 4),
                  Text(tab.title,
                      style: TextStyle(
                          color: isSelected ? tab.color : Colors.grey,
                          fontWeight: FontWeight.bold)),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 24,
                      decoration: BoxDecoration(
                        color: tab.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TabData {
  final String title;
  final IconData icon;
  final Color color;

  const TabData({
    required this.title,
    required this.icon,
    required this.color,
  });
}
