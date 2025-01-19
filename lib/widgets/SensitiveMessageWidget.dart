import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class SensitiveMessageWidget extends StatelessWidget {
  final Message message;

  const SensitiveMessageWidget({Key? key, required this.message})
      : super(key: key);

  String _maskSensitiveData(String text) {
    // Regular expression to identify phone numbers (basic example)
    final phoneRegex = RegExp(r'\b\d{10}\b');
    return text.replaceAllMapped(phoneRegex, (match) => '**********');
  }

  @override
  Widget build(BuildContext context) {
    // Check if the message has text and mask sensitive data
    final maskedText = message.text != null
        ? _maskSensitiveData(message.text!)
        : '';

    return ListTile(
      title: Text(maskedText),
      subtitle: Text('Sent by: ${message.user?.name ?? 'Unknown'}'),
    );
  }
}
