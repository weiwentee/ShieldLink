import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../../widgets/masked_chat_wrapper.dart';
import '../../../widgets/mask_message.dart';

class ChannelPage extends StatelessWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaskedChatWrapper(
      child: Scaffold(
        appBar: const StreamChannelHeader(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamMessageListView(
                threadBuilder: (_, parentMessage) => ThreadPage(
                  parent: parentMessage!,
                ),
                messageBuilder: (context, message, index, defaultWidget) {
                  // Only apply MaskMessage if it's a text message (no attachments)
                  if (message.message.attachments.isEmpty) {
                    return MaskMessage(message: message.message);
                  }
                  return defaultWidget;
                },
              ),
            ),
            const StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}

class ThreadPage extends StatefulWidget {
  const ThreadPage({Key? key, required this.parent}) : super(key: key);

  final Message parent;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late final _controller = StreamMessageInputController(
    message: Message(parentId: widget.parent.id),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaskedChatWrapper(
      child: Scaffold(
        appBar: StreamThreadHeader(parent: widget.parent),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamMessageListView(
                parentMessage: widget.parent,
                messageBuilder: (context, message, index, defaultWidget) {
                  // Only apply MaskMessage if it's a text message (no attachments)
                  if (message.message.attachments.isEmpty) {
                    return MaskMessage(message: message.message);
                  }
                  return defaultWidget;
                },
              ),
            ),
            StreamMessageInput(
              messageInputController: _controller,
            ),
          ],
        ),
      ),
    );
  }
}
