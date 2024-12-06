import 'package:flutter/material.dart';
import 'notification_page.dart';
import 'privacy_security_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.blue),
      body: ListView(
        children: [
          // Notification Section
          ListTile(
            title: const Text('Message Notifications'),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()),
                );
              },
            ),
          ),
          const Divider(),

          // Privacy & Security Section
          ListTile(
            title: const Text('Privacy & Security'),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacySecurityPage()),
                );
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
