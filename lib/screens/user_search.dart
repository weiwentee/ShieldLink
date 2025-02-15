import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:dio/dio.dart';
import '../screens/chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final StreamChatClient client;

  const UserSearchScreen({Key? key, required this.client}) : super(key: key);

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  final String backendUrl = 'http://192.168.79.14:3000'; // Backend URL

  /// 🔍 Search Users
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    try {
      print("🔹 Searching users with query: $query");

      final response = await widget.client.queryUsers(
        filter: Filter.and([
          Filter.autoComplete('name', query),
          Filter.notEqual('id', widget.client.state.currentUser?.id ?? ''),
        ]),
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

  /// 🔹 Start Chat with Selected User
  Future<void> _startChat(User selectedUser) async {
    final currentUser = widget.client.state.currentUser;
    if (currentUser == null) {
      print("❌ Error: Current user is null.");
      return;
    }

    try {
      print("🔹 Checking for existing chat with ${selectedUser.id}...");

      final List<Channel> existingChannels = await widget.client.queryChannels(
        filter: Filter.and([
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [currentUser.id, selectedUser.id]),
        ]),
        watch: true, // ✅ Ensure visibility
      ).first;

      Channel channel;
      if (existingChannels.isNotEmpty) {
        channel = existingChannels.first;
        print("🔄 Existing channel found: ${channel.id}");
      } else {
        channel = widget.client.channel(
          'messaging',
          id: '${currentUser.id}_${selectedUser.id}',
          extraData: {
            'members': [currentUser.id, selectedUser.id], // ✅ Force add members
            'created_by_id': currentUser.id, // ✅ Ensure ownership
          },
        );
        await channel.create();
        await channel.watch(); // ✅ Ensure updates
        print("✅ New channel created: ${channel.id}");
      }

      // ✅ Navigate to Chat Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(channel: channel),
        ),
      );
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
      body: _searchResults.isEmpty
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
