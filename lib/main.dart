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
import 'package:dio/dio.dart'; // For HTTP requests
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

const backendUrl = 'http://localhost:3000'; // Update with your deployed backend URL
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Firebase for Web
    await Firebase.initializeApp(options: firebaseWebConfig);
  } 
  
  else if (io.Platform.isAndroid) {

    await Firebase.initializeApp();
  }
  final client = StreamChatClient(streamKey);
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
      home: AuthenticationWrapper(client: client),
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
  final StreamChatClient client;
  
  const AuthenticationWrapper({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        if (snapshot.hasData) {
          // Connect the user to Stream
          final user = snapshot.data!;
          return FutureBuilder(
            future: _connectStreamUser(client, user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return HomeScreen();
            },
          );
        }
        return SplashScreen(child: LoginPage());
      },
    );
  }

  Future<void> _connectStreamUser(
      StreamChatClient client, firebase_auth.User user) async {
    final streamId = user.uid; 
    try{
      // fetch the Stream token from the backend
      final dio = Dio();
      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {'userId': streamId},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        
        // Connect the user to Stream Chat
        await client.connectUser(
          User(
            id: streamId,
            extraData: {
              'name': user.displayName ?? user.email ?? 'Anonymous',
            },
          ),
          token,
        );
      } else {
        throw Exception('Failed to fetch token from backend');
      }
    } catch (e) {
      print('Error connecting to Stream: $e');
      throw Exception('Stream Chat connection failed');
    }
  }
}