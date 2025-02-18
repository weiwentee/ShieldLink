import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../screens/chat_screen.dart';
import '../services/stream_chat_service.dart';
import 'package:dio/dio.dart';

class ContactsPage extends StatefulWidget {
  final StreamChatClient client;

  const ContactsPage({Key? key, required this.client}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<User> _users = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      print("Fetching users from Stream API...");
      
      final currentUser = widget.client.state.currentUser;
      if (currentUser == null) {
        throw Exception("Current user is null.");
      }

      final response = await widget.client.queryUsers(
        filter: Filter.notEqual('id', currentUser.id), // Exclude logged-in user
        pagination: PaginationParams(limit: 50), // Fetch up to 50 users
      );

      setState(() {
        _users = response.users;
        _isLoading = false;
      });

      print("Found ${_users.length} users (excluding self).");
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        _error = "Failed to load contacts.";
        _isLoading = false;
      });
    }
  }

  // Start Chat with Selected User
  Future<void> _startChat(User selectedUser) async {
    final currentUser = widget.client.state.currentUser;
    if (currentUser == null) {
      print("Error: Current user is null.");
      return;
    }

    try {
      print("Fetching Stream token from backend...");
      final dio = Dio();
      final response = await dio.post(
        'http://192.168.79.14:3000/generate-token', // Replace with your backend URL
        data: {'userId': currentUser.id, 'email': currentUser.extraData['email'] ?? ''},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final streamToken = response.data['token'];
        print("Token received: $streamToken");

        // Initialize Stream Chat Client
        await StreamChatService.initializeStreamChatClient(streamToken, currentUser.id, currentUser.name);

        print("Creating or fetching chat with ${selectedUser.id}...");
        final channel = await StreamChatService.createChannel(currentUser.id, selectedUser.id);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(channel: channel),
          ),
        );
      } else {
        print("Failed to fetch token from backend.");
      }
    } catch (e) {
      print("Error starting chat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.extraData['image'] as String? ?? ''),
                        child: user.extraData['image'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user.name),
                      onTap: () => _startChat(user),
                    );
                  },
                ),
    );
  }
}
