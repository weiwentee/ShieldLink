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
      if (mounted) {
        widget.onTimeOut(); // Execute timeout function
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("🚀 Session timeout listener started.");
    _startTimer(); // Start timer when widget initializes
  }

  @override
  void dispose() {
    print("🛑 Session timeout listener disposed.");
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        print("🖱 User tapped screen. Resetting timer.");
        _startTimer();
      },
      onPanUpdate: (_) {
        print("📜 User swiped. Resetting timer.");
        _startTimer();
      },
      child: Focus(
        autofocus: true,
        onKey: (_, __) {
          print("⌨️ User pressed a key. Resetting timer.");
          _startTimer();
          return KeyEventResult.handled;
        },
        child: widget.child,
      ),
    );
  }
}
