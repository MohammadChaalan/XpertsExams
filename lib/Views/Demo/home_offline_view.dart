import 'package:flutter/material.dart';
import 'package:xpertexams/Views/Demo/academy_offline_view.dart';

class HomeOfflineView extends StatefulWidget {
  const HomeOfflineView({super.key});

  @override
  State<HomeOfflineView> createState() => _HomeViewOfflineState();
}

class _HomeViewOfflineState extends State<HomeOfflineView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<TabData> tabs = const [
    TabData(title: "Academy", icon: Icons.school, color: Colors.green),
    TabData(title: "Wallet", icon: Icons.account_balance_wallet, color: Colors.green),
    TabData(title: "Jobs", icon: Icons.work, color: Colors.green),
  ];

  // Offline hardcoded tracks
  final List<Map<String, dynamic>> tracks = [
    {
      "id": 1,
      "name": "Flutter Track",
      "description": "Learn Flutter from basics to advanced",
    },
    {
      "id": 2,
      "name": "Dart Track",
      "description": "Master Dart programming language",
    },
    {
      "id": 3,
      "name": "Web Dev Track",
      "description": "HTML, CSS, JS",
    },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Welcome back, User",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabSection(),
          Expanded(
            child: PageView(
              key: const PageStorageKey('home_pageview_offline'),
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                AcademyViewOffline(),
                WalletViewOffline(),
                JobsViewOffline(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
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

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onButtonTap,
      selectedItemColor: Colors.green,
      items: tabs
          .map((tab) => BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.title))
          .toList(),
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


/// ---------------- Wallet Offline ----------------
class WalletViewOffline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Wallet (Offline)"));
  }
}

/// ---------------- Jobs Offline ----------------
class JobsViewOffline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Jobs (Offline)"));
  }
}
