import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat; // Alias for StreamChat User
import 'package:shieldlink/pages/messages_page.dart';
import 'package:shieldlink/pages/contacts_page.dart';
import 'package:shieldlink/widgets/icon_buttons.dart';
import 'package:shieldlink/screens/profile_screen.dart';
import 'package:shieldlink/widgets/glowing_action_button.dart';
import 'package:shieldlink/widgets/avatar.dart';
import 'package:shieldlink/screens/user_search.dart';
import 'package:shieldlink/theme.dart';
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart'; // Added for login screen
import 'package:shieldlink/screens/login_screen.dart'; // Added for login screen
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:stream_chat_flutter/stream_chat_flutter.dart'; // Stream Chat
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias Firebase Auth User
import 'package:shieldlink/features/authentication/screens/pages/login_screen.dart' as auth_page; // Alias for LoginPage

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Messages');
  List<Channel> channelsList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  @override
  void initState() {
    super.initState();
    _checkAuthentication(); // Check authentication status

    _fetchChannels();

    final client = StreamChat.of(context).client;

    // Listen for channel updates in real time
    client.on(EventType.channelUpdated).listen((_) {
      _fetchChannels();
    });
    client.on(EventType.notificationMessageNew).listen((_) {
      _fetchChannels();
    });
  }

  /// **Check if the user is authenticated**
  void _checkAuthentication() {
    final user = _auth.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => auth_page.LoginPage()), // Redirect to login
        );
      });
    } else {
      // Optionally, verify user email or username again to ensure correctness
      _verifyUserAccount(user);
    }
  }

  /// **Verify the current authenticated user**
  Future<void> _verifyUserAccount(firebase_auth.User user) async {
    // Here, you can check user email/username or perform any additional checks
    if (user.email == null || user.email == "") {
      // If the email is null or not set, you can sign out or take further action
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => auth_page.LoginPage()), // Redirect to login
      );
    }
  }

  /// **Fetch channels based on authenticated user**
  Future<void> _fetchChannels() async {
    final client = StreamChat.of(context).client;
    final user = _auth.currentUser; // Get logged-in user

    if (user == null) return; // Prevent fetching if user is null

    final filter = Filter.in_('members', [user.uid]);
    final sort = [SortOption<ChannelState>('last_message_at')];

    try {
      final channels = await client
          .queryChannels(
            filter: filter,
            channelStateSort: sort,
            watch: true,
            state: true,
          )
          .toList();

      setState(() {
        channelsList = channels.expand((channelList) => channelList).toList();
      });
    } catch (e) {
      print('Error fetching channels: $e');
    }
  }

  void _onNavigationItemSelected(int index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
  }

  final pageTitles = const [
    'Messages',
    'Contacts',
  ];

  List<Widget> _buildPages(BuildContext context) {
    final client = StreamChat.of(context).client; // Get Stream Chat Client

    return [
      MessagesPage(channels: channelsList),
      ContactsPage(client: client),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: Icons.search,
            onTap: () {
              print('TODO search');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: StreamBuilder<stream_chat.User?>(
              stream: StreamChat.of(context).client.state.currentUserStream,
              builder: (context, snapshot) {
                final user = snapshot.data;

                return GestureDetector(
                  onTap: user != null
                      ? () => Navigator.of(context).push(ProfileScreen.route)
                      : null, // Disable if user is null
                  child: user != null && user.image != null
                      ? Avatar.small(url: user.image!)
                      : const CircleAvatar(
                          backgroundColor: Colors.grey, // Placeholder color
                          child: Icon(Icons.person, color: Colors.white), // Default icon
                        ),
                );
              },
            ),
            ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _) {
          return _buildPages(context)[value];
        },
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemsSelected: _onNavigationItemSelected,
        onRefreshChannels: _fetchChannels,
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({
    Key? key,
    required this.onItemsSelected,
    required this.onRefreshChannels,
  }) : super(key: key);

  final ValueChanged<int> onItemsSelected;
  final VoidCallback onRefreshChannels;

  @override
  __BottomNavigationBarState createState() => __BottomNavigationBarState();
}

class __BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;

  void handleItemsSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemsSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationBarItem(
                index: 0,
                label: 'Messages',
                icon: Icons.message,
                isSelected: selectedIndex == 0,
                onTap: handleItemsSelected,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GlowingActionButton(
                  color: AppColors.secondary,
                  icon: Icons.add,
                  onPressed: () {
                    // Navigate to user search screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSearchScreen(
                          client: StreamChat.of(context).client,
                        ),
                      ),
                    );

                    // Refresh the channels list
                    widget.onRefreshChannels();
                  },
                ),
              ),
              _NavigationBarItem(
                index: 1,
                label: 'Contacts',
                icon: Icons.contacts,
                isSelected: selectedIndex == 1,
                onTap: handleItemsSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({
    Key? key,
    required this.index,
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.secondary : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.secondary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}