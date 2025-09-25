import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class CustomBottomBarPage extends StatefulWidget {
  const CustomBottomBarPage({super.key});

  @override
  State<CustomBottomBarPage> createState() => _CustomBottomBarPageState();
}

class _CustomBottomBarPageState extends State<CustomBottomBarPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home, label: "Home", route: AppRoute.home),
    _NavItem(icon: Icons.play_circle_fill, label: "Video", route: AppRoute.videoContent),
    _NavItem(icon: Icons.business_center, label: "Companies", route: "/companies"),
    _NavItem(icon: Icons.quiz, label: "Test", route: AppRoute.tracksContent),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    // Navigate to the route
    Get.offNamed(_navItems[index].route); // Use offNamed to avoid stacking pages
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? Colors.green : Colors.grey,
                    size: isSelected ? 30 : 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
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

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({required this.icon, required this.label, required this.route});
}
