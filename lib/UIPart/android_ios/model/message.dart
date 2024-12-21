class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timeSent;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final String recieverId_adId;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timeSent,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.recieverId_adId,
  });
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      text: json['text'],
      timeSent: DateTime.parse(json['timeSent']),
      isSeen: json['isSeen'],
      repliedMessage: json['repliedMessage'],
      repliedTo: json['repliedTo'],
      recieverId_adId: json['recieverId_adId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timeSent': timeSent.toIso8601String(),
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'recieverId_adId': recieverId_adId,
    };
  }
}
