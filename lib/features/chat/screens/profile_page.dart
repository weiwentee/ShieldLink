import 'package:flutter/material.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';

class ProfilePage extends StatelessWidget {
  final String userName = "John Doe";  // Example username
  final String imageUrl = "assets/user_icon/BMW_iX.jpg"; // JPG image in assets folder

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.blue),
      body: Center(  // This ensures the entire content is centered
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center,  // Center horizontally
            children: [
              // Circle-shaped image for user icon (using AssetImage for JPG)
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(imageUrl), // Using AssetImage for JPG
              ),
              const SizedBox(height: 20),
              // User's name below the image
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),  // Space between user info and logout button
              // Logout button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,  // Same color as appBar for consistency
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
