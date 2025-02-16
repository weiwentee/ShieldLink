import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class MaskMessage extends StatefulWidget {
  final Message message;

  const MaskMessage({Key? key, required this.message}) : super(key: key);

  @override
  _MaskMessageState createState() => _MaskMessageState();
}

class _MaskMessageState extends State<MaskMessage> {
  bool _isVisible = false;

  void _toggleVisibility(bool isPressed) {
    setState(() {
      _isVisible = isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMyMessage = widget.message.user?.id == StreamChat.of(context).currentUser?.id;

    return GestureDetector(
      onLongPressStart: (_) => _toggleVisibility(true),
      onLongPressEnd: (_) => _toggleVisibility(false),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMyMessage ? Colors.blue[200] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Text with Masking
              Stack(
                alignment: Alignment.center,
                children: [
                  // Hidden Text (Invisible by default)
                  Text(
                    widget.message.text ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.transparent),
                  ),

                  // Covering Blur Effect (No Eye Icon)
                  if (!_isVisible)
                    Positioned.fill(
                      child: Container(
                        color: Colors.grey.withOpacity(0.6), // Semi-transparent cover
                      ),
                    ),

                  // Actual Text (Visible on Long Press)
                  if (_isVisible)
                    Text(
                      widget.message.text ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                ],
              ),

              const SizedBox(height: 4),

            ],
          ),
        ),
      ),
    );
  }


}