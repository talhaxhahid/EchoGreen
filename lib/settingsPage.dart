import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _deleteUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete the user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await prefs.remove('user');
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete User'),
            onTap: () => _deleteUser(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.blue),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Navigate to Privacy Policy page or show content
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.article, color: Colors.green),
            title: const Text('Terms and Conditions'),
            onTap: () {
              // Navigate to Terms and Conditions page or show content
            },
          ),
        ],
      ),
    );
  }
}