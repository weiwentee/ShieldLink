import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shieldlink/app.dart';
// import 'package:shieldlink/features/authentication/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/global/toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shieldlink/screens/home_screen.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:dio/dio.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isSigningUp = false;
  bool _isPasswordVisible = false;

  final String backendUrl = 'http://192.168.79.14:3000'; // Update with your deployed backend URL

  @override
  void dispose() {
    _usernameController.dispose();
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

              // Username Text Field
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                cursorColor: Colors.blue,
              ),
              const SizedBox(height: 10),


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

  String maskSensitiveData(String text) {
    if (text.isEmpty) return text;

    // Mask the email address
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9._%+-]){1}([a-zA-Z0-9._%+-]*)@([a-zA-Z0-9]){1}([a-zA-Z0-9.-]*)\.([a-zA-Z]{2,})'),
      (match) => '${match.group(1)}***@${match.group(3)}****.${match.group(5)}',
    );

    return text;
  }

  // Signup function (preserved)
  Future<void> _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showToast(message: "All fields are required.");
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    if (password.length < 6) {
      showToast(message: "Password must be at least 6 characters.");
      setState(() {
        isSigningUp = false;
      });
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

    try {
      // Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Mask email address for logging/display purposes
      String maskedEmail = maskSensitiveData(email);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Logging masked email
      print('New user created: Email = $maskedEmail');

      // Connect user to Stream chat
      await _createStreamChatUser(user.uid, username, email);

      showToast(message: "Account created successfully.");
      Navigator.pushNamed(context, "/home");
    } catch (e) {
      showToast(message: "Sign up failed: $e");
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }

    Future<void> _createStreamChatUser(String streamId, String username, String email) async {
      try {
        print("🔹 Requesting Stream Chat token for user: $streamId ($email)");

        final dio = Dio();
        final response = await dio.post(
          '$backendUrl/generate-token',
          data: {'userId': streamId, 'email': email},
        );

        if (response.statusCode == 200 && response.data['token'] != null) {
          final token = response.data['token'];
          print("✅ Stream Chat token received: $token");

          final client = StreamChatCore.of(context).client;

          await client.connectUser(
            User(id: streamId, extraData: {'name': username, 'email': email}),
            token,
          );

          print("✅ User connected to Stream Chat successfully.");
        } else {
          throw Exception('Failed to fetch token from backend');
        }
      } catch (e) {
        print('❌ Error connecting to Stream Chat: $e');
        throw e;
      }
    }
}
