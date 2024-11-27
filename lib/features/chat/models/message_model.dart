// This model defines a basic message model

class MessageModel {
  final String text;
  final String senderId;
  final DateTime createdAt;

  MessageModel({
    required this.text,
    required this.senderId,
    required this.createdAt,
  });
}