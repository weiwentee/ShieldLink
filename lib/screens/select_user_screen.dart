import 'package:flutter/material.dart';
import 'package:shieldlink/screens/screens.dart';
import 'package:shieldlink/widgets/widgets.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:shieldlink/features/chat/models/chat_user_model.dart';

import 'package:shieldlink/app.dart';

class SelectUserScreen extends StatefulWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => const SelectUserScreen(),
      );

  const SelectUserScreen({Key? key}) : super(key: key);

  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  bool _loading = false;

  Future<void> onUserSelected(ChatUser user) async{
    setState(() {
      _loading = true;
    });

    try {
      final client = StreamChatCore.of(context).client;
      await client.connectUser(
        User(
          id: user.id,
          extraData: {
            'name': user.name,
            'image': user.image,
          },
        ),
        client.devToken(user.id).rawValue,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on Exception catch (e, st) {
      logger.e('Could not connect user', error: e, stackTrace: st);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: (_loading)
            ? const CircularProgressIndicator()
            : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Select a user',
                      style: TextStyle(fontSize: 24, letterSpacing: 0.4),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return SelectUserButton(
                          user: users[index],
                          onPressed: (user) => onUserSelected(user),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
      ),
    );
  }
}

class SelectUserButton extends StatelessWidget {
  const SelectUserButton({
    Key? key,
    required this.user,
    required this.onPressed,
  }) : super(key: key);

  final ChatUser user;

  final Function(ChatUser user) onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => onPressed(user),
        child: Row(
          children: [
            Avatar.large(url: user.image),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                user.name,
                style: const TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}