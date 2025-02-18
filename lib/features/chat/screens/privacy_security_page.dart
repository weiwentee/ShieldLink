import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  PrivacySecurityPageState createState() => PrivacySecurityPageState();
}

class PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool biometricUnlock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Privacy & Security'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // App Lock Section with Toggle for Biometrics
            ListTile(
              title: const Text('App Lock'),
              subtitle: const Text('Requires Biometrics to unlock'),
              trailing: Switch(
                value: biometricUnlock,
                onChanged: (value) {
                  setState(() {
                    biometricUnlock = value;
                  });
                },
                activeColor: Colors.blue,  
                inactiveThumbColor: Colors.white,  
                inactiveTrackColor: Colors.grey, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
