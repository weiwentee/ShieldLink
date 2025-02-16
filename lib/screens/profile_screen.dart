import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shieldlink/app.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';
import 'package:shieldlink/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:shieldlink/features/global/toast.dart';
import 'package:shieldlink/screens/screens.dart';
import 'package:shieldlink/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ProfileScreen extends StatelessWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Hero(
              tag: 'hero-profile-picture',
              child: Avatar.large(url: user?.image),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user?.name ?? 'No name'),
            ),
            const Divider(),
             // Fingerprint Tether Button (Added Below Sign-Out Button)
            ElevatedButton(
              onPressed: () => _linkAccountToFingerprint(context),
              child: const Text("Tether Account to Fingerprint"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
            const SizedBox(height: 20),
            const _SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatefulWidget {
  const _SignOutButton({
    Key? key,
  }) : super(key: key);

  @override
  __SignOutButtonState createState() => __SignOutButtonState();
}

class __SignOutButtonState extends State<_SignOutButton> {
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
    });

    try {
      await StreamChatCore.of(context).client.disconnectUser();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen(child: LoginPage())),
        (route) => false,
      );
    } on Exception catch (e, st) {
      logger.e('Could not sign out', error: e, stackTrace: st);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const CircularProgressIndicator()
        : TextButton(
            onPressed: _signOut,
            child: const Text('Sign out'),
          );
  }
}
Future<void> _linkAccountToFingerprint(BuildContext context) async {
    final LocalAuthentication localAuth = LocalAuthentication();

    // Check if biometric authentication is available
    bool isAvailable = await localAuth.canCheckBiometrics;
    if (!isAvailable) {
      showToast(message: "Biometric authentication is not available on this device.");
      return;
    }

    // Perform fingerprint authentication to link the account
    bool isAuthenticated = false;

    try {
      isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to link it to your account',
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
      // Successfully authenticated, link the fingerprint to the current account
      firebase.User? user = firebase.FirebaseAuth.instance.currentUser;

      if (user != null) {
        print("✅ Fingerprint Authentication Successful");
        showToast(message: "Fingerprint successfully linked to ${user.email}");

        // Save the fingerprint (or an indicator that it’s linked) in a secure way
        // You can store a flag in Firebase to mark the account as fingerprint-linked
        await _linkFingerprintToFirebaseAccount(user);

        // Proceed with further actions, e.g., go to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        showToast(message: "No user found. Please log in first.");
      }
    } else {
      showToast(message: "Fingerprint authentication failed.");
    }
  }

  // Function to save the fingerprint link information in Firestore
  Future<void> _linkFingerprintToFirebaseAccount(firebase.User user) async {
    try {
      // Access Firestore and store the `isFingerprintLinked` flag for the current user
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.set({
        'isFingerprintLinked': true,  // Mark the account as linked to a fingerprint
      }, SetOptions(merge: true));  // Merge with existing data to avoid overwriting other fields

      print("✅ Fingerprint successfully linked to account in Firebase!");
    } catch (e) {
      print("❌ Error linking fingerprint to Firebase: $e");
      showToast(message: "Failed to link fingerprint. Please try again.");
    }
  }
