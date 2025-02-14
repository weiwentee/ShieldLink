import 'package:flutter/material.dart';
import 'dart:async';

class SessionTimeOutListener extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback onTimeOut;

  const SessionTimeOutListener({
    super.key,
    required this.child,
    required this.duration,
    required this.onTimeOut,
  });

  @override
  State<SessionTimeOutListener> createState() => _SessionTimeOutListenerState();
}

class _SessionTimeOutListenerState extends State<SessionTimeOutListener> {
  Timer? _timer;

  void _startTimer() {
    print("🔄 Resetting inactivity timer...");
    _timer?.cancel(); // Cancel existing timer
    _timer = Timer(widget.duration, () {
      print("⏳ Session expired due to inactivity.");
      widget.onTimeOut(); // Execute timeout function
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start timer when widget initializes
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _startTimer, // Detect taps
      onPanUpdate: (_) => _startTimer(), // Detect scroll/swipe
      child: Focus(
        autofocus: true,
        onKey: (_, __) {
          _startTimer(); // Detect keyboard input
          return KeyEventResult.handled;
        },
        child: widget.child,
      ),
    );
  }
}
