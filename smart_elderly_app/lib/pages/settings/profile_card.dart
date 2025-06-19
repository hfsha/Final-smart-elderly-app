import 'package:flutter/material.dart';
import 'package:smart_elderly_app/models/user.dart';

class ProfileCard extends StatelessWidget {
  final User? user;

  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: Text(
                user?.name.substring(0, 1) ?? '?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Guest User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _editProfile(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // TODO: Implement profile editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile editing coming soon!')),
    );
  }
}
