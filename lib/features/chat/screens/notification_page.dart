import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool showNotifications = false;
  bool highMessagePreview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Show Notifications Toggle
            ListTile(
              title: const Text('Show Notifications'),
              trailing: Switch(
                value: showNotifications,
                onChanged: (value) {
                  setState(() {
                    showNotifications = value;
                  });
                },
                activeColor: Colors.blue,  // Active color blue
                inactiveThumbColor: Colors.white,  // Inactive thumb color white
                inactiveTrackColor: Colors.grey,  // Inactive track color grey
              ),
            ),
            const Divider(),

            // High Message Preview Toggle
            ListTile(
              title: const Text('High Message Preview'),
              trailing: Switch(
                value: highMessagePreview,
                onChanged: (value) {
                  setState(() {
                    highMessagePreview = value;
                  });
                },
                activeColor: Colors.blue,  // Active color blue
                inactiveThumbColor: Colors.white,  // Inactive thumb color white
                inactiveTrackColor: Colors.grey,  // Inactive track color grey
              ),
            ),
          ],
        ),
      ),
    );
  }
}
