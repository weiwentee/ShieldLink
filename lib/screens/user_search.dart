import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:dio/dio.dart';
import '../screens/chat_screen.dart';
import '../services/stream_chat_service.dart';

class UserSearchScreen extends StatefulWidget {
  final StreamChatClient client;

  const UserSearchScreen({Key? key, required this.client}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  final String backendUrl = 'http://192.168.79.14:3000'; // Backend URL

  @override
  void initState() {
    super.initState();
    _fetchAllUsers(); // Fetch all users on init
  }

  /// 🔹 Fetch all users (like ContactsPage)
  Future<void> _fetchAllUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final currentUser = widget.client.state.currentUser;
      if (currentUser == null) throw Exception("Current user is null.");

      final response = await widget.client.queryUsers(
        filter: Filter.notEqual('id', currentUser.id),
        pagination: PaginationParams(limit: 50),
      );

      setState(() {
        _searchResults = response.users;
        _isLoading = false;
      });

      print("✅ Loaded ${_searchResults.length} users.");
    } catch (e) {
      setState(() {
        _error = "Failed to load users.";
        _isLoading = false;
      });
      print("❌ Error fetching users: $e");
    }
  }

  /// 🔍 Search Users
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      _fetchAllUsers(); // Reset to all users if search is cleared
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await widget.client.queryUsers(
        filter: Filter.autoComplete('name', query),
        pagination: PaginationParams(limit: 10),
      );

      setState(() {
        _searchResults = response.users;
        _isLoading = false;
      });

      print("✅ Found ${_searchResults.length} users.");
    } catch (e) {
      setState(() {
        _error = "Search failed.";
        _isLoading = false;
      });
      print("❌ Error searching users: $e");
    }
  }

  /// 🔹 Start Chat with Selected User
  Future<void> _startChat(User selectedUser) async {
    final currentUser = widget.client.state.currentUser;
    if (currentUser == null) {
      print("❌ Error: Current user is null.");
      return;
    }

    try {
      print("🔹 Fetching Stream token from backend...");
      final dio = Dio();
      final response = await dio.post(
        '$backendUrl/generate-token',
        data: {'userId': currentUser.id, 'email': currentUser.extraData['email'] ?? ''},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final streamToken = response.data['token'];
        print("✅ Token received: $streamToken");

        // ✅ Initialize Stream Chat Client
        await StreamChatService.initializeStreamChatClient(streamToken, currentUser.id);

        print("🔹 Creating or fetching chat with ${selectedUser.id}...");
        final channel = await StreamChatService.createChannel(currentUser.id, selectedUser.id);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(channel: channel),
          ),
        );
      } else {
        print("❌ Failed to fetch token from backend.");
      }
    } catch (e) {
      print("❌ Error starting chat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by username...',
            border: InputBorder.none,
          ),
          onChanged: _searchUsers,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : _searchResults.isEmpty
                  ? const Center(child: Text("No users found"))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.extraData['image'] as String? ?? ''),
                          ),
                          title: Text(user.name),
                          onTap: () => _startChat(user),
                        );
                      },
                    ),
    );
  }
}
