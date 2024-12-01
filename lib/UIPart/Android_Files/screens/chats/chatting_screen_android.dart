import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChattingScreenAndroid extends ConsumerStatefulWidget {
  final String name;
  final String adImageUrl;
  final String adTitle;
  final String adId;
  final double price;
  final String recieverId;
  final String senderId;
  final DocumentReference<Map<String, dynamic>> documentReference;
  const ChattingScreenAndroid(
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
  ConsumerState<ChattingScreenAndroid> createState() =>
      _ChattingScreenAndroidState();
}

class _ChattingScreenAndroidState extends ConsumerState<ChattingScreenAndroid> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
