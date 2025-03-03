import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsHeader(),
          const SizedBox(height: 20),
          _buildSettingsOption(
            icon: Icons.person,
            title: 'Account',
            subtitle: 'Manage your account settings',
            onTap: () {
              // Handle account settings tap
            },
          ),
          _buildSettingsOption(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage your notification settings',
            onTap: () {
              // Handle notifications settings tap
            },
          ),
          _buildSettingsOption(
            icon: Icons.lock,
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              // Handle privacy settings tap
            },
          ),
          _buildSettingsOption(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Manage your language settings',
            onTap: () {
              // Handle language settings tap
            },
          ),
          _buildSettingsOption(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and support',
            onTap: () {
              // Handle help and support tap
            },
          ),
          _buildSettingsOption(
            icon: Icons.info,
            title: 'About',
            subtitle: 'Learn more about the app',
            onTap: () {
              // Handle about tap
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.pink.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Manage your preferences and settings',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }
}
