import 'package:flutter/material.dart';
import 'package:inventaris_app/personalinfo.dart';
import 'package:inventaris_app/templates/navbarwidget.dart';
import 'package:inventaris_app/suppliermanage.dart';

import 'accountmanagement.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Anna James',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text('Show profile', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Account settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(Icons.person, 'Personal information', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PersonalInformationPage(),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            'Management',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          _buildSettingTile(Icons.person_pin_rounded, 'Account Management', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountManagementPage(),
              ),
            );
          }),
          _buildSettingTile(Icons.person_add, 'Supplier Management', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupplierManagementPage(),
              ),
            );
          }),
          _buildSettingTile(Icons.analytics, 'Analytics', () {}),
          _buildSettingTile(Icons.notifications, 'Notifications', () {}),
          const SizedBox(height: 20),
          const Text(
            'Others',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          _buildSettingTile(Icons.logout, 'Logout', () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin logout?'),
                    actions: [
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
            );
          }),
        ],
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
