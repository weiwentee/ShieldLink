// TODO Implement this library.

  import 'dart:math';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';
  import 'package:shieldlink/features/authentication/firebase_auth_implementation/firebase_auth_services.dart';
  import 'package:shieldlink/features/authentication/screens/pages/reg_screen.dart';
  import 'package:dio/dio.dart';
  import 'package:shieldlink/features/global/toast.dart';
  import 'package:stream_chat_flutter/stream_chat_flutter.dart';
  import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
      as stream_chat;
  import 'package:local_auth/local_auth.dart';
  import 'package:shieldlink/screens/home_screen.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
  }

  const String backendUrl = 'http://192.168.1.13:3000';

  class _LoginPageState extends State<LoginPage> {
    bool _isSigning = true ;
    //false i changes this 1;
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

                // Login Button
                GestureDetector(
                  onTap: () {
                    _signIn(context);
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

  // 🔹 Optional Fingerprint Login Button
              ElevatedButton.icon(
  onPressed: () => _authenticateWithBiometrics(context), // ✅ Fix: Use a lambda function
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
                  GestureDetector(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 Normal Email & Password Login
  void _signIn(context) async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      firebase_auth.User? user =
          await _auth.signInWithEmailAndPassword(email, password);

      setState(() {
        _isSigning = false;
      });

      if (user != null) {
        showToast(message: "Successfully signed in!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(), // ✅ Navigate to home screen
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSigning = false;
      });

      String errorMessage = _handleLoginError(e);
      showToast(message: errorMessage);
    }
  }

  /// 🔥 Optional Fingerprint Login
  Future<void> _authenticateWithBiometrics(BuildContext context) async {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool isAuthenticated = false;

  // Check if biometric authentication is available
  bool isAvailable = await localAuth.canCheckBiometrics;
  if (!isAvailable) {
    showToast(message: "Biometric authentication is not available on this device.");
    return;
  }

  try {
    // Perform fingerprint authentication to log in
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
    // After successful authentication, get the current Firebase user
    firebase_auth.User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if the fingerprint is linked to the current Firebase account
      bool isFingerprintLinked = await _isFingerprintLinked(user);

      if (isFingerprintLinked) {
        // Fingerprint authentication successful and the fingerprint is linked
        print("✅ Fingerprint Authentication Successful");
        showToast(message: "Fingerprint login successful!");

        // Generate Firebase token and authenticate the user
        await _generateFirebaseToken(user);

        // Proceed to HomeScreen without needing password
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        showToast(message: "Fingerprint is not linked to your account.");
      }
    } else {
      showToast(message: "No user found. Please log in first.");
    }
  } else {
    showToast(message: "Fingerprint authentication failed.");
  }
}


Future<void> _connectStreamChatUser(firebase_auth.User user,context) async {
  try {
    final dio = Dio();

    // Send request to backend to generate a token for the Stream Chat user
    final response = await dio.post(
      '$backendUrl/generate-token',
      data: {
        'userId': user.uid,
        'email': user.email ?? 'anonymous@shieldlink.com',
      },
    );

    // Check the response
    if (response.statusCode == 200 && response.data['token'] != null) {
      final token = response.data['token'];

      // Get the Stream Chat client
      final client = StreamChatCore.of(context ).client;

      // Connect the user to Stream Chat using the token
      await client.connectUser(
        stream_chat.User(id: user.uid, extraData: {'email': user.email}),
        token,
      );

      print("✅ Stream Chat user connected successfully!");
    } else {
      throw Exception("❌ Failed to fetch token from backend.");
    }
  } catch (e) {
    print("❌ Error connecting to Stream: $e");
    showToast(message: "Failed to connect to Stream Chat.");
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
  
  Future<bool> _isFingerprintLinked(firebase_auth.User user) async {
  try {
    // Reference the user's document in Firestore using their UID
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    // Get the document snapshot
    final doc = await userRef.get();

    // If the document exists, check for the `isFingerprintLinked` flag
    if (doc.exists) {
      // Return true if `isFingerprintLinked` is true
      bool isFingerprintLinked = doc.data()?['isFingerprintLinked'] ?? false;
      return isFingerprintLinked;
    }
    return false; // If the document doesn't exist or flag is not set, return false
  } catch (e) {
    print("❌ Error checking fingerprint link: $e");
    return false; // If there's an error, return false
  }
}
Future<void> _generateFirebaseToken(firebase_auth.User user) async {
  try {
    // Generate Firebase custom token (ID token) for the currently authenticated user
    String? token = await FirebaseAuth.instance.currentUser!.getIdToken();

    // Check if the token is null
    if (token == null) {
      throw Exception("Token generation failed");
    }

    // Debug: Print the token to check if it's valid
    print("✅ Firebase Token Generated: $token");

    // Authenticate the user using the generated token (skip password)
    firebase_auth.UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(token);

    // Debug: Confirm the user is authenticated
    print("✅ User signed in with custom token. User email: ${userCredential.user?.email}");

    // After successful authentication, connect Stream Chat
    await  _connectStreamChatUser(user,context);

    // Proceed to HomeScreen after successful authentication
    Navigator.pushReplacement(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  } catch (e) {
    print("❌ Error generating Firebase token: $e");
    showToast(message: "Failed to authenticate with fingerprint. Please try again.");
  }
}

Future<void> _connectStreamChatUser(firebase_auth.User user,context) async {
  try {
    final dio = Dio();

    // Send request to backend to generate a token for the Stream Chat user
    final response = await dio.post(
      '$backendUrl/generate-token',
      data: {
        'userId': user.uid,
        'email': user.email ?? 'anonymous@shieldlink.com',
      },
    );

    // Check the response
    if (response.statusCode == 200 && response.data['token'] != null) {
      final token = response.data['token'];

      // Get the Stream Chat client
      final client = StreamChatCore.of(context ).client;

      // Connect the user to Stream Chat using the token
      await client.connectUser(
        stream_chat.User(id: user.uid, extraData: {'email': user.email}),
        token,
      );

      print("✅ Stream Chat user connected successfully!");
    } else {
      throw Exception("❌ Failed to fetch token from backend.");
    }
  } catch (e) {
    print("❌ Error connecting to Stream: $e");
    showToast(message: "Failed to connect to Stream Chat.");
  }
}
