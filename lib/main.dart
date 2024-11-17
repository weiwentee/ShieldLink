import 'package:flutter/material.dart';
import 'package:shieldlink/features/authentication/screens/login_screen.dart';

void main() {
  runApp(ShieldLink());
}

class ShieldLink extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shield Link',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}