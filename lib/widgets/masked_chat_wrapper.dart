import 'dart:async';
import 'package:flutter/material.dart';

class MaskedChatWrapper extends StatefulWidget {
  final Widget child;
  const MaskedChatWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _MaskedChatWrapperState createState() => _MaskedChatWrapperState();
}

class _MaskedChatWrapperState extends State<MaskedChatWrapper> {
  bool _isScreenInactive = false;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    print("Started inactivity timer");
    _inactivityTimer?.cancel(); // Cancel existing timer if any
    _inactivityTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isScreenInactive = true;
        });
      }
    });
  }

  void _resetInactivityTimer() {
    print("User active, resetting timer");
    setState(() {
      _isScreenInactive = false;
    });
    _startInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Ensures it captures taps everywhere
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(), // Detects scrolling
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              _resetInactivityTimer();
              return false;
            },
            child: widget.child, // The chat UI
          ),
          if (_isScreenInactive)
            Container(
              color: Colors.black.withOpacity(0.7), // Dark overlay effect
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _resetInactivityTimer,
                    child: const Text("Resume"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
