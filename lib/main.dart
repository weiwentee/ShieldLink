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
import 'package:shieldlink/screens/user_search.dart';
import 'package:shieldlink/screens/home_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'; // For StreamChatLocalizations
import 'package:stream_chat_localizations/stream_chat_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io' as io; // Import to detect platforms
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

const streamApiKey = 'qg3xperd8afd';
const backendUrl = 'http://localhost:3000'; // Update with your deployed backend URL
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

  // Initialize Stream Chat Client
  final client = StreamChatClient(
    streamApiKey, 
    logLevel: Level.INFO
  ); // Replace with your StreamChat key

  runApp(ShieldLink(client: client));
}

class ShieldLink extends StatelessWidget { 
  final StreamChatClient client;

  const ShieldLink({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shield Link',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalStreamChatLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: AuthenticationWrapper(client: client),

      builder: (context, child) {
        return StreamChat(
          client: client,
          child: StreamChatCore(client: client, child: child!),
        );
      },
      
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
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
        if (snapshot.hasData && snapshot.data != null) {
          // Connect the user to Stream
          final user = snapshot.data!;
          if (user.uid.isEmpty) {
            throw Exception('User ID is null or empty');
          }
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

    if (streamId == null) {
      throw Exception('User ID is null');
    }

    try{
      // fetch the Stream token from the backend
      final dio = Dio();
      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {'userId': streamId},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        
        // Connect the user to Stream Chat
        await client.connectUser(
          User(
            id: streamId,
            name: user.displayName ?? user.email ?? 'Anonymous',
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