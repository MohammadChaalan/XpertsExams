import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class CustomBottomBarPage extends StatefulWidget {
  const CustomBottomBarPage({super.key});

  @override
  State<CustomBottomBarPage> createState() => _CustomBottomBarPageState();
}

class _CustomBottomBarPageState extends State<CustomBottomBarPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, String route) {
    setState(() {
      _selectedIndex = index;
    });
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, AppRoute.home , "Home"),
          _buildNavItem(Icons.play_circle, 1, "/video" , "Video"),
          _buildNavItem(Icons.business, 2, "/companies", "Companies"),
          _buildNavItem(Icons.quiz, 3, AppRoute.tracksContent , "Test"),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String route , String text) {
    final isSelected = _selectedIndex == index;
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isSelected ? Colors.green : Colors.grey,
            size: isSelected ? 30 : 26,
          ),
          onPressed: () => _onItemTapped(index, route),
        ),
        Text(text , style: TextStyle(color: isSelected ? Colors.green : Colors.grey, ),),
      ],
    );
  }
}
