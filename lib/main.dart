import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shieldlink/app.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/authentication/screens/splash_screen/splash_screen.dart';
// import 'package:shieldlink/features/authentication/screens/temp_success_screen.dart';
import 'package:shieldlink/features/authentication/screens/pages/reg_screen.dart';
// import 'package:shieldlink/features/chat/screens/chat_list_screen.dart';
// import 'package:shieldlink/features/chat/screens/chat_screen.dart';
// import 'package:shieldlink/features/chat/services/chat_services.dart';
import 'dart:io' as io; // Import to detect platforms
import 'package:flutter/foundation.dart';
import 'package:shieldlink/screens/select_user_screen.dart';
import 'package:shieldlink/screens/home_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart'; // For kIsWeb

// Replace these values with your Firebase project's settings
const firebaseWebConfig = FirebaseOptions(
  apiKey: "AIzaSyAd4mgByMtt2_s3Arxg_KWLxf9vUq6pZQI",
  authDomain: "shieldlink-b052c.firebaseapp.com",
  projectId: "shieldlink-b052c",
  storageBucket: "shieldlink-b052c.firebasestorage.app",
  messagingSenderId: "1004734408718",
  appId: "1:1004734408718:web:a5b243f8749a8824a9745f",
  measurementId: "G-3Y3BYT6G83"
);

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Firebase for Web
    await Firebase.initializeApp(options: firebaseWebConfig);
  } 
  else if (io.Platform.isAndroid) {
    // Firebase for Android
    await Firebase.initializeApp();
  }

  final client = StreamChatClient('your_stream_key_here'); // Replace with your StreamChat key
  runApp(
    ShieldLink(
      client: client,
    ),
  );
}

class ShieldLink extends StatelessWidget {
  const ShieldLink({super.key, required this.client});

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shield Link',
      home: AuthenticationWrapper(),
      builder: (context, child) {
        return StreamChatCore(
          client: client,
          child: child!,
        );
      },
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
        '/selectUser': (context) => SelectUserScreen(),
      },
    );
  }
}   

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } 
        if (snapshot.hasData) {
          return SelectUserScreen();
        }
        return SplashScreen(child: LoginPage());
      },
    );
  }
}
