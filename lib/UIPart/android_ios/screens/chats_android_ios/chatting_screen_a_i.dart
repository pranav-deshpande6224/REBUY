import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChattingScreenAI extends ConsumerStatefulWidget {
  final String name;
  final String adImageUrl;
  final String adTitle;
  final String adId;
  final double price;
  final String recieverId;
  final String senderId;
  final DocumentReference<Map<String, dynamic>> documentReference;
  const ChattingScreenAI(
      {required this.name,
      required this.recieverId,
      required this.senderId,
      required this.documentReference,
      required this.adImageUrl,
      required this.adTitle,
      required this.adId,
      required this.price,
      super.key});

  @override
  ConsumerState<ChattingScreenAI> createState() => _ChattingScreenAIState();
}

class _ChattingScreenAIState extends ConsumerState<ChattingScreenAI> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
