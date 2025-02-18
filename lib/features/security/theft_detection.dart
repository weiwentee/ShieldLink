import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';

class TheftDetection extends StatefulWidget {
  final Widget child;
  static TheftDetectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<TheftDetectionState>();
  }

  const TheftDetection({Key? key, required this.child}) : super(key: key);

  @override
  State<TheftDetection> createState() => TheftDetectionState();
}

class TheftDetectionState extends State<TheftDetection> with WidgetsBindingObserver {
  double threshold = 100.0; 
  double spikeThreshold = 10.0; 
  bool isLocked = false;
  bool _ignoreMovement = false; 
  DateTime? lastHighMovementTime; 
  final int gracePeriodMilliseconds = 2000; 
  final int cooldownMilliseconds = 5000;
  double lastMovement = 0.0;
  StreamSubscription? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMonitoring();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startMonitoring() {
    List<double> recentMovements = [];
    const int bufferSize = 10;

    _accelerometerSubscription = SensorsPlatform.instance.accelerometerEvents.listen((event) {
      if (!mounted) return;

      try {
        double movement = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
        double movementChange = (movement - lastMovement).abs();

        print('Detected movement: $movement');

        if (_ignoreMovement) {
          print("File just selected, ignoring movement temporarily...");
          return;
        }

        if (recentMovements.length >= bufferSize) {
          recentMovements.removeAt(0);
        }
        recentMovements.add(movement);

        double avgMovement = recentMovements.reduce((a, b) => a + b) / recentMovements.length;

        if (avgMovement > threshold) {
          lastHighMovementTime ??= DateTime.now();
        } else {
          lastHighMovementTime = null;
        }

        if (lastHighMovementTime != null &&
            DateTime.now().difference(lastHighMovementTime!) > Duration(milliseconds: gracePeriodMilliseconds) &&
            !isLocked) {
          print('Movement sustained above threshold. Locking...');
          _lockDevice();
        }

        if (movementChange > spikeThreshold && !isLocked) {
          print('Sudden movement detected! Locking...');
          _lockDevice();
        }

        lastMovement = movement;
      } catch (e) {
        print('Error reading accelerometer data: $e');
      }
    });
  }

  void _lockDevice() {
    if (!isLocked && mounted) {
      setState(() {
        isLocked = true;
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LockScreen()),
        );
      }
    }
  }

  void startCooldown() {
    setState(() {
      _ignoreMovement = true;
    });

    Future.delayed(Duration(milliseconds: cooldownMilliseconds), () {
      if (mounted) {
        setState(() {
          _ignoreMovement = false;
        });
        print("Cooldown ended. Theft detection re-enabled.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class LockScreen extends StatelessWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theft Detection - Locked'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Device Locked! Please log in again to unlock.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Unlock Device'),
            ),
          ],
        ),
      ),
    );
  }
}