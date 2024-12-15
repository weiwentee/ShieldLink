import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shieldlink/features/authentication/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/global/toast.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isSigningUp = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Sign Up"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/logos/main logo.svg",
                width: 120,
                height: 120,
              ),
              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Email Text Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                keyboardType: TextInputType.emailAddress,
                cursorColor: Colors.blue,
              ),
              const SizedBox(height: 10),

              // Password Text Field with Eye Icon
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: const UnderlineInputBorder(),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                cursorColor: Colors.blue,
              ),
              const SizedBox(height: 30),

              GestureDetector(
                onTap: () {
                  _signUp(); // Existing signup logic
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isSigningUp
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5),

                  // Cursor Hover for Login Link
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Signup function (preserved)
  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          isSigningUp = false;
        });
        showToast(message: "All fields are required.");
        return;
      }

      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(email)) {
        setState(() {
          isSigningUp = false;
        });
        showToast(message: "Please enter a valid email address.");
        return;
      }

      if (password.length < 6) {
        setState(() {
          isSigningUp = false;
        });
        showToast(message: "Password must be at least 6 characters.");
        return;
      }

      User? user = await _auth.signUpWithEmailAndPassword(email, password);
      setState(() {
        isSigningUp = false;
      });

      if (user != null) {
        showToast(message: "Account created successfully.");
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      setState(() {
        isSigningUp = false;
      });
      String errorMessage = _handleSignUpError(e);
      showToast(message: errorMessage);
    }
  }

  String _handleSignUpError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is not valid. Please check it again.';
        case 'weak-password':
          return 'Password is too weak. Please choose a stronger password.';
        default:
          // return 'An unexpected error occurred. Please try again later.';
          return ':D';
      }
    } else {
      // return 'An unknown error occurred. Please try again later.';
      return ':DD';
    }
  }
}
