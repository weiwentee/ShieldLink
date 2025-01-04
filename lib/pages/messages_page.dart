import 'package:flutter/material.dart';
import 'package:shieldlink/features/chat/models/message_data.dart';
import 'package:shieldlink/helpers.dart';
import 'package:shieldlink/theme.dart';
import 'package:shieldlink/widgets/avatar.dart';
import 'package:faker/faker.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:jiffy/jiffy.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('MessagesPage'),
//     );
//   }
// }


      @override
        Widget build(BuildContext context) {
          return CustomScrollView(
            slivers: [          
              SliverToBoxAdapter(
                child: _Stories(), // Placeholder Stories widget
              ),
              // Placeholder for Message List
              SliverList(
                delegate: SliverChildBuilderDelegate(_delegate)),
              
            ],
          );
        }
        Widget _delegate(BuildContext context, int index) {
          final Faker faker = Faker();
          final date = Helpers.randomDate();
          return _MessageTile(messageData: MessageData(
            senderName: faker.person.name(),
            message: faker.lorem.sentence(), 
            messageDate: date, 
            dateMessage: Jiffy.parseFromDateTime(date).fromNow(), 
            profileProfile: Helpers.randomPictureUrl()),);
        }
      }

      

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300, // Placeholder background color
            child: const Icon(Icons.person, color: Colors.white), // Placeholder icon
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageData.senderName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  letterSpacing: 0.2,
                  wordSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 20,
                child: Text(
                  messageData.message,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textFaded,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 0,
          child: SizedBox(
            height: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 16),
                  child: Text(
                    'Stories',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.grey, // Placeholder text color
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10, // Number of placeholder stories
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 60,
                          child: _StoryCard(
                            storyData: StoryData(
                              name: 'User $index', // Placeholder name
                              url: '', // Placeholder for empty image URL
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.storyData, Key? key}) : super(key: key);

  final StoryData storyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Placeholder circle without an image
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade300, // Placeholder avatar color
          child: const Icon(Icons.person, color: Colors.white), // Replace with an icon
        ),
        const SizedBox(height: 8),
        // Display the story name
        Text(
          storyData.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

  class StoryData {
    final String name;
    final String url;

    StoryData({required this.name, required this.url});
  }
