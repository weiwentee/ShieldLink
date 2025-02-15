// lib/services/user_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'stream_chat_service.dart';  // Importing StreamChatService to use the token


class UserService {
  static Future<void> sendUserDataToBackend(String userId) async {
    final Uri url = Uri.parse('http://localhost:3000/generate-token'); // Replace with your backend URL
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        // Successfully sent data to the backend
         final responseData = json.decode(response.body);
        String token = responseData['token']; // Assuming the backend sends the token as 'token'
        print('User data sent to backend successfully');
      await StreamChatService.initializeStreamChatClient(token, userId);
        
        print('User data sent to backend and Stream Chat initialized successfully');
      } else {
        // Handle any error response
        print('Failed to send user data to backend');
      }
    } catch (e) {
      print('Error sending user data to backend: $e');
    }
  }
}