import 'package:flutter/material.dart';
import 'package:xpertexams/Core/AppBar/HomeAppBar.dart';
import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
import 'package:xpertexams/Views/home/Academy_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedIndex = 0;
  bool _isAnimationReady = false;

  final List<TabData> tabs = [
    TabData(title: "Academy", icon: Icons.school, color: Colors.green),
    TabData(title: "Wallet", icon: Icons.account_balance_wallet, color: Colors.green),
    TabData(title: "Jobs", icon: Icons.work, color: Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward().then((_) {
      setState(() {
        _isAnimationReady = true;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onButtonTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
       appBar: CustomAppBar(
        title: "Welcome back, User",
        subtitle: "Ready to continue your learning journey?",
        onMenuTap: () {
          print("Menu tapped");
        },
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
                AcademyView(), // no controller here
                Center(child: Text("Wallet Page")),
                Center(child: Text("Jobs Page")),
              ],
            ),
          ),
        ],
      ),
          bottomNavigationBar: CustomBottomBarPage(),

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

        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = _selectedIndex == index;
            return Expanded(
              child: TextButton(
                onPressed: () => _onButtonTap(index),
                child: Text(tab.title, style: TextStyle(color: isSelected ? tab.color : Colors.grey)),
              ),
            );
          }),
        ),
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
