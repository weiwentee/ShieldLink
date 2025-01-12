import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:shieldlink/helpers.dart';
import 'package:shieldlink/pages/messages_page.dart';
import 'package:shieldlink/pages/notifications_page.dart';
import 'package:shieldlink/pages/calls_page.dart';
import 'package:shieldlink/pages/contacts_page.dart';
import 'package:shieldlink/screens/screens.dart';
import 'package:shieldlink/screens/user_search.dart';
import 'package:shieldlink/theme.dart';
import 'package:shieldlink/widgets/avatar.dart';
import 'package:shieldlink/widgets/glowing_action_button.dart';
import 'package:shieldlink/widgets/icon_buttons.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:shieldlink/app.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Messages');

  List<Widget> _buildPages(BuildContext context) {
    final client = StreamChat.of(context).client;
    final channelsList = client.state.channels.values.toList();

    return [
      MessagesPage(channels: channelsList),
      NotificationsPage(),
      CallsPage(),
      ContactsPage(),
    ];
  }

  final pageTitles = const [
    'Messages',
    'Notifications',
    'Calls',
    'Contacts',
  ];

  void _onNavigationItemSelected(index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
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
            child: Avatar.small(url: context.currentUserImage,
            onTap: () {
              Navigator.of(context).push(ProfileScreen.route);
            },),
          )
        ]
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _) {
          return _buildPages(context)[value];
        },
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemsSelected: _onNavigationItemSelected,
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({
    Key? key, 
    required this.index,
    required this.lable,
    required this.icon,
    this.isSelected = false,
    required this.OnTap,
  }) : super(key: key);

  final int index;
  final String lable;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> OnTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        OnTap(index);
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 20,
              color: isSelected ? AppColors.secondary : null
            ),
            const SizedBox(
              height: 8
            ),
            Text(
              lable, 
              style: isSelected
                ? const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                )
              : const TextStyle(fontSize: 11),
            ),
          ],
        ),
      )
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({
    Key? key,
    required this.onItemsSelected,
  }) : super(key: key);

  final ValueChanged<int> onItemsSelected;

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
                lable: 'Messages',
                icon: CupertinoIcons.bubble_left_bubble_right_fill, 
                isSelected: (selectedIndex == 0),             
                OnTap: handleItemsSelected,
              ),
              _NavigationBarItem(
                index: 1,
                lable: 'Notifications',
                icon: CupertinoIcons.bell_solid,
                isSelected: (selectedIndex == 1),
                OnTap: handleItemsSelected,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child:GlowingActionButton(
                  color: AppColors.secondary, 
                  icon: CupertinoIcons.add, onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSearchScreen(client: StreamChat.of(context).client),
                      ),
                    );
                    print('TODO add');
                  },
                ),
              ),
              _NavigationBarItem(
                index: 2,
                lable: 'Calls',
                icon: CupertinoIcons.phone_fill,
                isSelected: (selectedIndex == 2),
                OnTap: handleItemsSelected,
              ),
              _NavigationBarItem(
                index: 3,
                lable: 'Contacts',
                icon: CupertinoIcons.person_2_fill,
                isSelected: (selectedIndex == 3),
                OnTap: handleItemsSelected,
              ),
            ],
          )
        ),
      ),
    );
  }
}