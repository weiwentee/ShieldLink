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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local_auth/local_auth.dart';


// Firebase configuration
const firebaseWebConfig = FirebaseOptions(
  apiKey: "AIzaSyAd4mgByMtt2_s3Arxg_KWLxf9vUq6pZQI",
  authDomain: "shieldlink-b052c.firebaseapp.com",
  projectId: "shieldlink-b052c",
  storageBucket: "shieldlink-b052c.firebasestorage.app",
  messagingSenderId: "1004734408718",
  appId: "1:1004734408718:android:83d074cd7c61b7bfa9745f",
  measurementId: "G-3Y3BYT6G83",
);

const streamApiKey = 'qg3xperd8afd';
const backendUrl = 'http://192.168.79.14:3000';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseWebConfig);
  } else if (io.Platform.isAndroid) {
    await Firebase.initializeApp();
  }

  final client = StreamChatClient(
    streamApiKey,
    logLevel: Level.INFO,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request Permission for Notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("Notification permission: ${settings.authorizationStatus}");

  // Get the FCM Token
  String? fcmToken = await messaging.getToken();
  print("FCM Token: $fcmToken");

  if (fcmToken != null) {
    try {
      await client.addDevice(
        fcmToken,
        PushProvider.firebase,
        pushProviderName: "FirebasePushNotifs",
      );
      print("FCM Token registered with Stream");
    } catch (e) {
      print("Error adding device to Stream: $e");
    }
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

// Convert AuthenticationWrapper into a StatefulWidget to force UI rebuilds
class AuthenticationWrapper extends StatefulWidget {
  final StreamChatClient client;

  const AuthenticationWrapper({super.key, required this.client});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> with WidgetsBindingObserver {
  firebase_auth.User? _user;
  final LocalAuthentication localAuth = LocalAuthentication();
  bool _isAuthenticated = true ;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForAuthChanges(); // Listen for authentication changes
    _checkAuthentication(); // Check authentication status at startup
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Listen for authentication changes and rebuild UI when user logs in
  void _listenForAuthChanges() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  /// Check if the user is authenticated
  void _checkAuthentication() {
    final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser; // Check the current user
    if (user == null) {
      // If the user is not logged in, redirect to login page
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to login
        );
      });
    } else {
      // Verify user email or username again to ensure correctness
      _verifyUserAccount(user);
    }
  }

  // Verify the current authenticated Firebase user
  Future<void> _verifyUserAccount(firebase_auth.User user) async {
    // Check user email/username
    if (user.email == null || user.email!.isEmpty) {
      // If the email is null or empty, sign the user out and redirect to login
      await firebase_auth.FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to login
      );
    }
  }


  // Detect when app comes back from the background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _user != null) {
      print("App resumed. Resetting session timeout.");
      setState(() {}); // Forces rebuild and restarts SessionTimeOutListener
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return SplashScreen(child: LoginPage());
    }

    print("User is logged in. Starting session timeout listener...");

    return SessionTimeOutListener(
      duration: Duration(minutes: 20),
      onTimeOut: () async {
        print("Session expired. Logging out...");

        try {
          // Sign out from Firebase
          await firebase_auth.FirebaseAuth.instance.signOut();
          print("Firebase sign out successful.");

          // Disconnect from Stream Chat
          await widget.client.disconnectUser();
          print("Stream Chat user disconnected.");

          print("Session completely cleared.");

          // Redirect user to login page
          if (context.mounted) {
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            });
          }
        } catch (e) {
          print('Error signing out: $e');
        }
      },
      child: FutureBuilder(
        future: _connectStreamUser(widget.client, _user!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Wrap HomeScreen with TheftDetection so that Theft Lock works properly
          return TheftDetection(child: HomeScreen());
        },
      ),
    );
  }

  // Connect user to Stream Chat API
  Future<void> _connectStreamUser(StreamChatClient client, firebase_auth.User user) async {
    final streamId = user.uid;

    if (streamId.isEmpty) {
      throw Exception('User ID is null or empty');
    }

    try {
      final dio = Dio();
      print("Requesting Stream Chat token for $streamId...");

      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {'userId': streamId, 'email': user.email ?? 'anonymous@shieldlink.com'},
      );

      print("Backend response: ${response.data}");

      if (response.statusCode == 200 && response.data['token'] != null) {
        await client.connectUser(
          User(id: streamId, name: user.displayName ?? user.email ?? 'Anonymous'),
          response.data['token'],
        );

        print("Stream Chat user connected successfully!");
      } else {
        throw Exception("Failed to fetch token from backend.");
      }
    } catch (e) {
      print("Error connecting to Stream Chat: $e");
      throw Exception('Stream Chat connection failed.');
    }
  }
}
