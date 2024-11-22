import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100), // Top spacing
                Center(
                  child: SvgPicture.asset(
                    'assets/logos/shield.svg',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Organisation ID',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Enter Organisation ID' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Employee ID',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Enter Employee ID' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Enter your password' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      // Navigate to SuccessScreen after validation
                      Navigator.pushNamed(context, '/success');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/register'); // Navigate to RegistrationScreen
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'New Organisation? ',
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Register now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
