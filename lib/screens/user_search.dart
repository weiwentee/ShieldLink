import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:dio/dio.dart';
import 'chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final StreamChatClient client;

  const UserSearchScreen({Key? key, required this.client}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  final String backendUrl = 'http://192.168.1.10:3000'; // Backend URL

  // ✅ Search Users
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    try {
      print("🔹 Searching users with query: $query");

      final response = await widget.client.queryUsers(
        filter: Filter.autoComplete('id', query),
        pagination: PaginationParams(limit: 10),
      );

      setState(() {
        _searchResults = response.users;
      });

      print("✅ Found ${_searchResults.length} users.");
    } catch (e) {
      print("❌ Error searching users: $e");
    }
  }

  // ✅ Start Chat with Selected User
  Future<void> _startChat(User selectedUser) async {
    final currentUser = widget.client.state.currentUser;

    if (currentUser == null) {
      print("❌ Error: Current user is null.");
      return;
    }

    final currentUserId = currentUser.id;

    try {
      final dio = Dio();
      print("🔹 Sending request to create channel...");

      final response = await dio.post(
        'http://192.168.1.10:3000/create-channel',
        data: {'userId': currentUserId, 'recipientId': selectedUser.id},
      );

      print("📥 Response from backend: ${response.data}");

      // ✅ Check if the channel was successfully created
      if (response.statusCode == 200 && response.data['channelId'] != null) {
        final channelId = response.data['channelId'];

        // ✅ Get the created channel
        final channel = widget.client.channel(
          'messaging',
          id: channelId,
        );

        await channel.watch(); // ✅ Ensure real-time updates

        print("✅ Successfully created channel: $channelId");

        // ✅ Navigate to chat screen
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StreamChannel(
            channel: channel,
            child: ChatScreen(),
          ),
        ));
      } else {
        print("❌ Failed to create channel. Response: ${response.data}");
        throw Exception('Failed to create channel');
      }
    } catch (e) {
      print("❌ Error creating channel: $e");
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
      body: ListView.builder(
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
