import 'package:flutter/material.dart';
import 'package:shieldlink/features/authentication/screens/login_screen.dart';
import 'package:shieldlink/features/authentication/screens/temp_success_screen.dart';
import 'package:shieldlink/features/authentication/screens/reg_screen.dart';

void main() {
  runApp(const ShieldLink());
}

class ShieldLink extends StatelessWidget {
  const ShieldLink({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shield Link',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/success': (context) => const SuccessScreen(),
        '/register': (context) => const RegistrationScreen(), // New Route
      },
    );
  }
}
