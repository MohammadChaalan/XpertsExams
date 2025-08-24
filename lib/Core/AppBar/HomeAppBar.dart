import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onMenuTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      backgroundColor: Colors.green[400],
      toolbarHeight: 80, // 👈 increase height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24), // 👈 curved bottom design
        ),
      ),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.list, size: 28, color: Colors.white),
        onPressed: onMenuTap,
      ),
      title: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, size: 26, color: Colors.white),
          onPressed: onNotificationTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ✅ Required to set AppBar height correctly
  @override
  Size get preferredSize => const Size.fromHeight(80);
}
