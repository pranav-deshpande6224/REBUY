import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String contactId;
  final String lastMessage;
  final String nameOfContact;
  final DateTime timeSent;
  final DocumentReference<Map<String, dynamic>> reference;
  final bool isSeen;
  final String lastMessageId;
  final String postedByUserId;
  final String adTitle;
  final String adImage;
  final String adId;
  final double adPrice;

  Contact({
    required this.id,
    required this.contactId,
    required this.lastMessage,
    required this.nameOfContact,
    required this.timeSent,
    required this.reference,
    required this.isSeen,
    required this.lastMessageId,
    required this.postedByUserId,
    required this.adTitle,
    required this.adImage,
    required this.adId,
    required this.adPrice,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      contactId: json['contactId'],
      lastMessage: json['lastMessage'],
      nameOfContact: json['nameOfContact'],
      timeSent: DateTime.parse(json['timeSent']),
      reference: json['reference'],
      isSeen: json['isSeen'],
      lastMessageId: json['lastMessageId'],
      postedByUserId: json['postedByUserId'],
      adTitle: json['adTitle'],
      adImage: json['adImage'],
      adId: json['adId'],
      adPrice: json['adPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'lastMessage': lastMessage,
      'nameOfContact': nameOfContact,
      'timeSent': timeSent.toIso8601String(),
      'reference': reference,
      'isSeen': isSeen,
      'lastMessageId': lastMessageId,
      'postedByUserId': postedByUserId,
      'adTitle': adTitle,
      'adImage': adImage,
      'adId': adId,
      'adPrice': adPrice,
    };
  }
}
