import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
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

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    final response = await widget.client.queryUsers(
      filter: Filter.autoComplete('id', query),
      pagination: PaginationParams(limit: 10),
    );

    setState(() {
      _searchResults = response.users;
    });
  }

  Future<void> _startChat(User selectedUser) async {
    final currentUserId = widget.client.state.currentUser!.id;

    final channel = widget.client.channel(
      'messaging',
      extraData: {
        'members': [currentUserId, selectedUser.id],
      },
    );

    await channel.create();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StreamChannel(
        channel: channel,
        child: ChatScreen(),
      ),
    ));
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
