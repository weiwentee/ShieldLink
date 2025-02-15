import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shieldlink/features/authentication/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shieldlink/features/authentication/screens/pages/reg_screen.dart';
import 'package:dio/dio.dart';
import 'package:shieldlink/features/global/toast.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart' as stream_chat;
import 'package:local_auth/local_auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

const String backendUrl = 'http://192.168.1.10:3000';

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
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
    backgroundColor: Colors.white,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text("Login"),
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
              'assets/logos/main logo.svg',
              width: 120,
              height: 120,
            ),
            const Text(
              "Login",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Email Field
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

            // Password Field
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
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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

            // Login Button
            GestureDetector(
              onTap: () {
                _signIn();
              },
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: _isSigning
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🔥 New Fingerprint Login Button
            ElevatedButton.icon(
              onPressed: _authenticateWithBiometrics,
              icon: Icon(Icons.fingerprint, size: 24),
              label: Text("Login with Fingerprint"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                const SizedBox(width: 5),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Sign Up",
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

  

  void _signIn() async {
  setState(() {
    _isSigning = true;
  });
  
  

  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = await auth.canCheckBiometrics;
  bool isAuthenticated = false;

  if (canCheckBiometrics) {
    try {
      isAuthenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to log in',
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      showToast(message: 'Biometric authentication failed. Please try again.');
    }
  }

  if (isAuthenticated) {
    // Auto-login user if biometric authentication succeeds
    firebase_auth.User? user = _firebaseAuth.currentUser;
    
    if (user != null) {
      showToast(message: "Fingerprint login successful!");
      
      // Send request to backend to generate Stream Chat token
      await _createStreamChatUser(user.uid, user.email!);
      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "No saved login found. Please sign in manually.");
    }

    setState(() {
      _isSigning = false;
    });
    return;
  }

  // If biometric authentication fails or is not available, proceed with manual login
  String email = _emailController.text;
  String password = _passwordController.text;

  try {
    firebase_auth.User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: "Successfully signed in!");
      
      // Send request to backend to generate Stream Chat token
      await _createStreamChatUser(user.uid, email);
      Navigator.pushNamed(context, "/home");
    }
  } catch (e) {
    setState(() {
      _isSigning = false;
    });

    String errorMessage = _handleLoginError(e);
    showToast(message: errorMessage);
  }
}
Future<void> _authenticateWithBiometrics() async {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool isAuthenticated = false;

  try {
    isAuthenticated = await localAuth.authenticate(
      localizedReason: 'Scan your fingerprint to log in',
      options: AuthenticationOptions(
        biometricOnly: true,
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );
  } on PlatformException catch (e) {
    print("❌ Biometric Error: ${e.message}");
    showToast(message: "Biometric authentication failed. Try again.");
    return;
  }

  if (isAuthenticated) {
    print("✅ Fingerprint Authentication Successful");
    showToast(message: "Fingerprint login successful!");

    firebase_auth.User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _createStreamChatUser(user.uid, user.email!);
      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "No saved login found. Please sign in manually.");
    }
  }
}


  Future<void> _createStreamChatUser(String userId, String email) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {
          'userId': userId,
          'email': email,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];

        final client = StreamChatCore.of(context).client;
        await client.connectUser(
          stream_chat.User(
            id: userId,
            extraData: {'email': email}),
          token,
        );
        print('Stream Chat user connected');
      } else {
        throw Exception('Failed to fetch token from backend');
      }
    } catch (e) {
      print('Error connecting to Stream: $e');
      throw Exception('Stream Chat connection failed');
    }
  }

  String _handleLoginError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'An unexpected error occurred. Please try again later.';
      }
    } else {
      return 'An unknown error occurred. Please try again later.';
    }
    
  }
}


