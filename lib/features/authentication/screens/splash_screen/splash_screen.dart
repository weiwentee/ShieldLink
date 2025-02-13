import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller and fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    // Start the fade-out animation after a 2-second delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { // ✅ Ensure widget is still in the tree
        _controller.forward().whenComplete(() {
          if (mounted) { // ✅ Ensure widget is still in the tree before navigation
            _navigateToNextScreen();
          }
        });
      }
    });
  }

  void _navigateToNextScreen() {
    if (mounted) { // ✅ Check again before navigating
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.child!),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SVG Image
              SvgPicture.asset(
                'assets/logos/main logo.svg', // Path to your SVG file
                width: 150, // Adjust width as needed
                height: 150, // Adjust height as needed
              ),
              const SizedBox(height: 20),
              // Welcome Text
              const Text(
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
      ),
    );
  }
}
