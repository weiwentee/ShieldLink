import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for 3 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // Navigate back after 3 seconds
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress indicator animation
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 6,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
                // Tick icon
                const Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 80,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Login Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the login screen immediately
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
