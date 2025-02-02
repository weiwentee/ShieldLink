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
import 'package:shieldlink/features/security/theft_detection.dart';
import 'package:shieldlink/screens/user_search.dart';
import 'package:shieldlink/screens/home_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'; // For StreamChatLocalizations
import 'package:stream_chat_localizations/stream_chat_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dio/dio.dart'; // For HTTP requests
// Replace these values with your Firebase project's settings
import 'package:shieldlink/screens/home_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shieldlink/utils/session_listener.dart'; // Import your SessionTimeOutListener

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
const backendUrl = 'http://localhost:3000';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseWebConfig);
  } else if (io.Platform.isAndroid) {
    await Firebase.initializeApp();
  }

  final client = StreamChatClient(
    streamApiKey,
    logLevel: Level.INFO,
  );

  runApp(ShieldLink(client: client)); // Running ShieldLink widget
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
              return SessionTimeOutListener( // Wrap HomeScreen with SessionTimeOutListener
                // child: TheftDetection(child: HomeScreen()),
                child: HomeScreen(),
                duration: Duration(minutes: 5), // Set your session timeout duration
                // duration: Duration(minutes: 1), // For demonstration
                onTimeOut: () async {
                  // Log out of Firebase on session timeout
                  try {
                    await firebase_auth.FirebaseAuth.instance.signOut(); // Firebase sign-out
                    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
                  } catch (e) {
                    print('Error signing out: $e'); // Handle any errors during sign-out
                  }
                },
              );
            },
          );
        }
        return SplashScreen(child: LoginPage());
      },
    );
  }

  Future<void> _connectStreamUser(StreamChatClient client, firebase_auth.User user) async {
    final streamId = user.uid;

    if (streamId == null) {
      throw Exception('User ID is null');
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {'userId': streamId},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];

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
