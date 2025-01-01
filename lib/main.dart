import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/authentication/screens/splash_screen/splash_screen.dart';
// import 'package:shieldlink/features/authentication/screens/temp_success_screen.dart';
import 'package:shieldlink/features/authentication/screens/pages/reg_screen.dart';
// import 'package:shieldlink/features/chat/screens/chat_list_screen.dart';
// import 'package:shieldlink/features/chat/screens/chat_screen.dart';
// import 'package:shieldlink/features/chat/services/chat_services.dart';
import 'dart:io' as io; // Import to detect platforms
import 'package:flutter/foundation.dart';
import 'package:shieldlink/screens/home_screen.dart'; // For kIsWeb
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

    await Firebase.initializeApp();
  }

  runApp(const ShieldLink());
}

class ShieldLink extends StatelessWidget {
  const ShieldLink({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shield Link',
      home: AuthenticationWrapper(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}   

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } 
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return SplashScreen(child: LoginPage());
      },
    );
  }
}
      
    
      // initialRoute: '/login',
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/success': (context) => const SuccessScreen(),
      //   '/register': (context) => const RegistrationScreen(),
      
