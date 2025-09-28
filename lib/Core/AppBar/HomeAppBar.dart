import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Routes/AppRoute.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onMenuTap;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    required this.onMenuTap,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  build(BuildContext context) {
    final signInController = Get.find<SignInController>();
    final isLoggedIn = signInController.user.value != null;

    return AppBar(
      elevation: 4,
      backgroundColor: Colors.green[400],
      toolbarHeight: 80,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.list, size: 28, color: Colors.white),
        onPressed: () => _showUserMenu(context, signInController),
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
          if (subtitle != null)
            Text(
              subtitle!,
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
          icon: Icon(
            Icons.notifications,
            size: 26,
            color: isLoggedIn ? Colors.white : Colors.white70, // dim if locked
          ),
          onPressed: () {
            if (isLoggedIn) {
              // logged in → go to notifications
              if (onNotificationTap != null) {
                onNotificationTap!();
             
                Get.toNamed(AppRoute.notifications);
              }
            } else {
              // not logged in → show dialog
              _showLoginRequiredDialog(context);
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

/// User Menu (when clicking left drawer icon)
void _showUserMenu(BuildContext context, SignInController signInController) {
  final user = signInController.user.value;
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await signInController.logout();

                Get.snackbar(
                  "Logged Out",
                  "You have successfully logged out",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );

                Get.offAllNamed(AppRoute.login);
              },
            ),
          ],
        ),
      );
    },
  );
}

/// Login Required Dialog
void _showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Login Required"),
      content:
          const Text("You must be logged in to access notifications."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Get.offAllNamed(AppRoute.login);
          },
          child: const Text("Login"),
        ),
      ],
    ),
  );
}
