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

// 🔥 Firebase web configuration
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
const backendUrl = 'http://192.168.79.14:3000';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔍 Initialize Firebase
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
      home: AuthenticationWrapper(client: client), // 🔥 Entry point: AuthenticationWrapper
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

// ✅ Convert AuthenticationWrapper into a StatefulWidget to force UI rebuilds
class AuthenticationWrapper extends StatefulWidget {
  final StreamChatClient client;

  const AuthenticationWrapper({super.key, required this.client});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  firebase_auth.User? _user;

  @override
  void initState() {
    super.initState();
    _listenForAuthChanges();
  }

  // ✅ Listen for authentication changes and rebuild UI when user logs in
  void _listenForAuthChanges() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return SplashScreen(child: LoginPage());
    }

    print("✅ User is logged in. Starting session timeout listener...");

    return SessionTimeOutListener(
      // duration: Duration(seconds: 20), // ⏳ Set timeout duration
      duration: Duration(minutes: 20), // ⏳ Set timeout duration
      onTimeOut: () async {
        print("⚠️ Session expired. Logging out...");

        try {
          // 1️⃣ Sign out from Firebase
          await firebase_auth.FirebaseAuth.instance.signOut();
          print("✅ Firebase sign out successful.");

          // 2️⃣ Disconnect from Stream Chat
          await widget.client.disconnectUser();
          print("✅ Stream Chat user disconnected.");

          // 3️⃣ Clear user session storage (if applicable)
          // Example: If you're storing user details in shared preferences, clear them
          // final prefs = await SharedPreferences.getInstance();
          // await prefs.clear();

          print("✅ Session completely cleared.");

          // 4️⃣ Redirect user to login page
          if (context.mounted) {
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            });
          }
        } catch (e) {
          print('❌ Error signing out: $e');
        }
      },
      child: FutureBuilder(
        future: _connectStreamUser(widget.client, _user!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Wrap HomeScreen with TheftDetection so that Theft Lock works properly
          return TheftDetection(child: HomeScreen());
        },
      ),
    );
  }

  // 🔹 Connect user to Stream Chat API
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
