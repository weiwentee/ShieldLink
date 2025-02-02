// For technical review, to be shown on web

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';

class TheftDetection extends StatefulWidget {
  final Widget child;

  const TheftDetection({Key? key, required this.child}) : super(key: key);

  @override
  State<TheftDetection> createState() => _TheftDetectionState();
}

class _TheftDetectionState extends State<TheftDetection> with WidgetsBindingObserver {
  double threshold = 15.0; // Sensitivity threshold
  double spikeThreshold = 10.0; // Sudden spike threshold
  bool isLocked = false;
  DateTime? lastHighMovementTime; // For grace period
  final int gracePeriodMilliseconds = 2000; // 2-second grace period
  double lastMovement = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startMonitoring() {
  if (kIsWeb) {
    print('Running on web. Simulating movement...');
    
    // Simulate a movement event every 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      double simulatedMovement = 20.0; // Simulated movement value
      print('Simulated movement detected: $simulatedMovement');

      if (simulatedMovement > threshold) {
        print('Simulated movement exceeds threshold! Locking device...');
        _lockDevice();
      }
    });
  } else {
    // Normal device sensor-based monitoring
    List<double> recentMovements = [];
    const int bufferSize = 10; // Buffer for averaging
    SensorsPlatform.instance.accelerometerEvents.listen((AccelerometerEvent event) {
      try {
        double movement = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
        double movementChange = (movement - lastMovement).abs();

        print('Detected movement: $movement');

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
}


  void _lockDevice() {
    if (!isLocked) {
      setState(() {
        isLocked = true;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LockScreen()),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !isLocked) {
      print('App moved to background. Locking device...');
      _lockDevice();
    }
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

// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart';

// class TheftDetection extends StatefulWidget {
//   final Widget child;

//   const TheftDetection({Key? key, required this.child}) : super(key: key);

//   @override
//   State<TheftDetection> createState() => _TheftDetectionState();
// }

// class _TheftDetectionState extends State<TheftDetection> with WidgetsBindingObserver {
//   double threshold = 15.0; // Sensitivity threshold
//   double spikeThreshold = 10.0; // Sudden spike threshold
//   bool isLocked = false;
//   DateTime? lastHighMovementTime; // For grace period
//   final int gracePeriodMilliseconds = 2000; // 2-second grace period
//   double lastMovement = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _startMonitoring();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   void _startMonitoring() {
//     List<double> recentMovements = [];
//     const int bufferSize = 10; // Buffer for averaging

//     SensorsPlatform.instance.accelerometerEvents.listen((AccelerometerEvent event) {
//       try {
//         double movement = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
//         double movementChange = (movement - lastMovement).abs();

//         print('Detected movement: $movement');

//         // Store movement history for better detection
//         if (recentMovements.length >= bufferSize) {
//           recentMovements.removeAt(0);
//         }
//         recentMovements.add(movement);

//         double avgMovement = recentMovements.reduce((a, b) => a + b) / recentMovements.length;

//         // Check for consistent high movement over grace period
//         if (avgMovement > threshold) {
//           lastHighMovementTime ??= DateTime.now();
//         } else {
//           lastHighMovementTime = null;
//         }

//         // If movement remains high for the grace period, trigger lock
//         if (lastHighMovementTime != null &&
//             DateTime.now().difference(lastHighMovementTime!) > Duration(milliseconds: gracePeriodMilliseconds) &&
//             !isLocked) {
//           print('Movement sustained above threshold. Locking...');
//           _lockDevice();
//         }

//         // Detect sudden spikes in movement
//         if (movementChange > spikeThreshold && !isLocked) {
//           print('Sudden movement detected! Locking...');
//           _lockDevice();
//         }

//         lastMovement = movement;
//       } catch (e) {
//         print('Error reading accelerometer data: $e');
//       }
//     });
//   }

//   void _lockDevice() {
//     if (!isLocked) {
//       setState(() {
//         isLocked = true;
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LockScreen()),
//       );
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused && !isLocked) {
//       print('App moved to background. Locking device...');
//       _lockDevice();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

// class LockScreen extends StatelessWidget {
//   const LockScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Theft Detection - Locked'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Device Locked! Please log in again to unlock.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 );
//               },
//               child: const Text('Unlock Device'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }