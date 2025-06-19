import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/auth_service.dart';
import 'package:smart_elderly_app/widgets/settings_item.dart';
import 'profile_card.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xF5F3F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientPurple,
                AppColors.gradientBlue,
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          children: [
            ProfileCard(user: user),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            SettingsItem(
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
            ),
            SettingsItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  // TODO: Implement theme switching
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Account'),
            SettingsItem(
              icon: Icons.security,
              title: 'Change Password',
              onTap: () => _showChangePasswordDialog(),
            ),
            SettingsItem(
              icon: Icons.devices,
              title: 'Connected Devices',
              onTap: () => _showConnectedDevices(),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            SettingsItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () => _showHelpSupport(),
            ),
            SettingsItem(
              icon: Icons.info,
              title: 'About App',
              onTap: () => _showAboutApp(),
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(authService),
            const SizedBox(height: 24),
          ].animate().fadeIn(duration: 500.ms).slideY(begin: 0.08),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 151, 35, 35), // Maroon
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _confirmLogout(authService),
        child: const Text('Logout'),
      ),
    );
  }

  Future<void> _confirmLogout(AuthService authService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    // TODO: Implement password change
  }

  void _showConnectedDevices() {
    // TODO: Implement connected devices view
  }

  void _showHelpSupport() {
    // TODO: Implement help and support
  }

  void _showAboutApp() {
    showLicensePage(
      context: context,
      applicationName: 'Smart Elderly Monitor',
      applicationVersion: '1.0.0',
    );
  }
}
