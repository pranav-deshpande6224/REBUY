import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReply {
  final String message;
  final bool isMe;
  MessageReply({required this.message, required this.isMe});
}

final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);