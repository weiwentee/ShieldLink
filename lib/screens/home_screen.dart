import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:shieldlink/pages/messages_page.dart';
import 'package:shieldlink/pages/notifications_page.dart';
import 'package:shieldlink/pages/calls_page.dart';
import 'package:shieldlink/pages/contacts_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pages  = const [
    MessagesPage(),
    NotificationsPage(),
    CallsPage(),
    ContactsPage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[0],
      bottomNavigationBad: _BottomNavigationBar(onItemsSelected: onItemsSelected)
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    Key? key,
    required this.onItemsSelected,
  }) : super(key: key);

  final ValueChanged<int> onItemsSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationBarItem(
            index: 0,
            lable: 'Messaging',
            icon: Icons.message,              
            OnTap: onItemsSelected,
          ),
          _NavigationBarItem(
            index: 1,
            lable: 'Notifications',
            icon: Icons.notifications,
            OnTap: onItemsSelected,
          ),
          _NavigationBarItem(
            index: 2,
            lable: 'Calls',
            icon: Icons.call,
            OnTap: onItemsSelected,
          ),
          _NavigationBarItem(
            index: 3,
            lable: 'Contacts',
            icon: Icons.contacts,
            OnTap: onItemsSelected,
          ),
        ],
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
    required this.OnTap,
  }) : super(key: key);


  final int index;
  final String lable;
  final IconData icon;
  final ValueChanged<int> OnTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        OnTap(index);
      },
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(lable, style: const TextStyle(fontSize: 11),),
          ],
        ),
      )
    );
  }
}