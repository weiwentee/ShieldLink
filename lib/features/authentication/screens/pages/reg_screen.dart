import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shieldlink/features/authentication/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/authentication/screens/widgets/form_container_widget.dart';
import 'package:shieldlink/features/global/toast.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Sign Up"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  _signUp();
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
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

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

      // Basic email validation
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(email)) {
        setState(() {
          isSigningUp = false;
        });
        showToast(message: "Please enter a valid email address.");
        return;
      }

      // Check password strength (at least 6 characters)
      if (password.length < 6) {
        setState(() {
          isSigningUp = false;
        });
        showToast(message: "Password must be at least 6 characters.");
        return;
      }

      // Attempt to create the user
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
          return 'An unexpected error occurred. Please try again later.';
      }
    } else {
      return 'An unknown error occurred. Please try again later.';
    }
  }
}
