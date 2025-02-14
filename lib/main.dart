import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io; // Import to detect platforms
import 'package:flutter/foundation.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:shieldlink/features/authentication/screens/pages/reg_screen.dart';
import 'package:shieldlink/features/security/theft_detection.dart';
import 'package:shieldlink/screens/home_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:stream_chat_localizations/stream_chat_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dio/dio.dart';
import 'package:shieldlink/utils/session_listener.dart';

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
const backendUrl = 'http://192.168.1.10:3000';

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
      supportedLocales: const [Locale('en')],
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
              
              print("✅ User is logged in. Starting session timeout listener...");

              return SessionTimeOutListener(
                child: TheftDetection(child: HomeScreen()),
                duration: Duration(seconds: 5),
                onTimeOut: () async {
                  try {
                    await firebase_auth.FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    print('Error signing out: $e');
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

    if (streamId.isEmpty) {
      throw Exception('User ID is null or empty');
    }

    try {
      final dio = Dio(BaseOptions(connectTimeout: Duration(milliseconds: 5000), receiveTimeout: Duration(milliseconds: 5000)));
      print("🔹 Requesting Stream Chat token for $streamId...");

      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {'userId': streamId, 'email': user.email ?? 'anonymous@shieldlink.com'},
      );

      print("🔹 Backend response: ${response.data}");

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];

        await client.connectUser(
          User(id: streamId, name: user.displayName ?? user.email ?? 'Anonymous'),
          token,
        );

        print("✅ Stream Chat user connected successfully!");
      } else {
        throw Exception("❌ Failed to fetch token from backend.");
      }
    } catch (e) {
      print("❌ Error connecting to Stream Chat: $e");
      throw Exception('Stream Chat connection failed.');
    }
  }
}
