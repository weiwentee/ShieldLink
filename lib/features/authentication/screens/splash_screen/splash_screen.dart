import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 3), () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget.child!), (route) => false);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG Image
            SvgPicture.asset(
              'assets/logos/main logo.svg', // Path to your SVG file
              width: 150, // Adjust width as needed
              height: 150, // Adjust height as needed
            ),
            SizedBox(height: 20),
            // Welcome Text
            Text(
              "Welcome to ShieldLink!",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 24, // Adjust font size as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
