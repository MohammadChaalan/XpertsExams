import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
import 'package:xpertexams/Core/common_colors/color_extension.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'company_details_view.dart';

class CompaniesView extends StatelessWidget {
  CompaniesView({super.key});

  // Demo data
  final List<Map<String, String>> companies = [
    {
      "name": "Tech Solutions Inc.",
      "industry": "Software Development",
      "location": "New York, USA",
      "description": "Leading software solutions provider with global reach."
    },
    {
      "name": "Green Energy Co.",
      "industry": "Renewable Energy",
      "location": "San Francisco, USA",
      "description": "Innovative renewable energy solutions for a sustainable future."
    },
    {
      "name": "HealthPlus",
      "industry": "Healthcare",
      "location": "London, UK",
      "description": "Providing top-quality healthcare services worldwide."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title:  Text("Companies" , style: TextStyle(color: TColor.textSecondaryAppbar , fontWeight: FontWeight.bold),),
            centerTitle: true,
            leading: IconButton(
              icon:  Icon(Icons.menu, color: TColor.primary),
              onPressed: () {
                _showUserMenu(context);
              },
            ),
          ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return _buildCompanyCard(context, company);
        },
      ),
            bottomNavigationBar: const CustomBottomBarPage(initialIndex: 2),

    );
  }
void _showUserMenu(BuildContext context) {
    final signInController = Get.find<SignInController>();
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
               CircleAvatar(
                radius: 40,
                backgroundColor: TColor.primary,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
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

  Widget _buildCompanyCard(BuildContext context, Map<String, String> company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: TColor.primary.withOpacity(0.2),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(company['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("${company['industry']} • ${company['location']}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyDetailsView(company: company),
            ),
          );
        },
      ),
    );
  }
}
