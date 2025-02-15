import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class TouchID extends StatefulWidget {
  @override
  _TouchIDState createState() => _TouchIDState();
}

class _TouchIDState extends State<TouchID> {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool _canCheckBiometric = false;
  String _authorizeText = 'Not Authorized!';

  Future<void> _authorize() async {
    bool isAuthorized = false;
    try {
      isAuthorized = await localAuth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }

    if (!mounted) return;

    setState(() {
      _authorizeText = isAuthorized ? "Authorized Successfully!" : "Not Authorized!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fingerprint Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _authorizeText,
              style: TextStyle(color: Colors.black38, fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Authenticate', style: TextStyle(fontSize: 20)),
              onPressed: _authorize,
            ),
          ],
        ),
      ),
    );
  }
}
