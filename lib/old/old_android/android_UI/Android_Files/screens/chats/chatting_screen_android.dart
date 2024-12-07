import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/Providers/active_inactive_send.dart';
import 'package:resell/UIPart/android_ios/Providers/message_reply_provider.dart';
import 'package:resell/UIPart/android_ios/model/contact.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';
import 'package:resell/UIPart/android_ios/model/message.dart';
import 'package:uuid/uuid.dart';

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
  late AuthHandler handler;

  Stream<List<Message>> getMessages(String receiverId, String itemid) {
    return handler.fireStore
        .collection('users')
        .doc(handler.newUser.user!.uid)
        .collection('chats')
        .doc("${receiverId}_$itemid")
        .collection('messages')
        .orderBy('timeSent', descending: false)
        .snapshots()
        .asyncMap((event) async {
      List<Message> messages = [];
      for (var doc in event.docs) {
        var message = Message.fromJson(doc.data());
        messages.add(message);
      }
      return messages.reversed.toList();
    });
  }

  // String _formatLastSeen(int millisecondsSinceEpoch) {
  //   final DateTime now = DateTime.now();
  //   final DateTime dateTime =
  //       DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  //   final DateFormat timeFormat =
  //       DateFormat('h:mm a'); // e.g., 12:30 AM, 1:00 PM
  //   final String formattedTime = timeFormat.format(dateTime);

  //   final Duration difference = now.difference(dateTime);

  //   if (difference.inDays == 0) {
  //     // Same day
  //     return 'last seen today at $formattedTime';
  //   } else if (difference.inDays == 1) {
  //     // Yesterday
  //     return 'last seen yesterday at $formattedTime';
  //   } else if (difference.inDays < 7) {
  //     // Within the last week
  //     final String weekday =
  //         DateFormat.EEEE().format(dateTime); // e.g., Monday, Tuesday
  //     return 'last seen on $weekday at $formattedTime';
  //   } else {
  //     // More than a week ago, display date and time
  //     final DateFormat dateFormat = DateFormat('yMMMd'); // e.g., Oct 24, 2024
  //     return 'last seen on ${dateFormat.format(dateTime)} at $formattedTime';
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sendMessageToDb(
      String message, Item item, MessageReply? messageReply) async {
   // chatController.text = '';
    ref.read(messageReplyProvider.notifier).update((state) => null);
    ref.read(activeInactiveSendProvider.notifier).reset();
    if (handler.newUser.user != null) {
      try {
        await handler.fireStore.runTransaction(
          (transaction) async {
            final firestore = handler.fireStore;
            DocumentSnapshot<Map<String, dynamic>> somedoc = await firestore
                .collection('users')
                .doc(widget.recieverId)
                .get();
            final name = somedoc.data()!['firstName'];
            var timeSent = DateTime.now();
            final messageId = const Uuid().v1();
            final postedAdContact = Contact(
                id: "${widget.recieverId}_${item.id}",
                contactId: widget.recieverId,
                lastMessage: message,
                nameOfContact: name,
                timeSent: timeSent,
                reference: widget.documentReference,
                isSeen: false,
                lastMessageId: handler.newUser.user!.uid,
                postedByUserId: item.userid,
                adTitle: item.adTitle,
                adImage: item.images[0],
                adId: item.id,
                adPrice: item.price);
            final replyingToAdContact = Contact(
                id: "${widget.senderId}_${item.id}",
                contactId: handler.newUser.user!.uid,
                lastMessage: message,
                nameOfContact: handler.newUser.user!.displayName!,
                timeSent: timeSent,
                reference: widget.documentReference,
                isSeen: false,
                lastMessageId: handler.newUser.user!.uid,
                postedByUserId: item.userid,
                adTitle: item.adTitle,
                adImage: item.images[0],
                adId: item.id,
                adPrice: item.price);

            await firestore
                .collection('users')
                .doc(widget.senderId)
                .collection('chats')
                .doc("${widget.recieverId}_${item.id}")
                .set(postedAdContact.toJson());
            await firestore
                .collection('users')
                .doc(widget.recieverId)
                .collection('chats')
                .doc("${widget.senderId}_${item.id}")
                .set(
                  replyingToAdContact.toJson(),
                );
            await firestore
                .collection('users')
                .doc(widget.senderId)
                .collection('chats')
                .doc("${widget.recieverId}_${item.id}")
                .collection('messages')
                .doc(messageId)
                .set(
                  Message(
                    messageId: messageId,
                    senderId: widget.senderId,
                    receiverId: widget.recieverId,
                    text: message,
                    timeSent: timeSent,
                    isSeen: false,
                    repliedMessage:
                        messageReply == null ? '' : messageReply.message,
                    repliedTo: messageReply == null
                        ? ''
                        : messageReply.isMe
                            ? handler.newUser.user!.displayName!
                            : name,
                  ).toJson(),
                );
            await firestore
                .collection('users')
                .doc(widget.recieverId)
                .collection('chats')
                .doc("${widget.senderId}_${item.id}")
                .collection('messages')
                .doc(messageId)
                .set(
                  Message(
                    messageId: messageId,
                    senderId: widget.senderId,
                    receiverId: widget.recieverId,
                    text: message,
                    timeSent: timeSent,
                    isSeen: false,
                    repliedMessage:
                        messageReply == null ? '' : messageReply.message,
                    repliedTo: messageReply == null
                        ? ''
                        : messageReply.isMe
                            ? handler.newUser.user!.displayName!
                            : name,
                  ).toJson(),
                );
          },
        );
      } catch (e) {
        if (Platform.isAndroid) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: GoogleFonts.roboto(),
                ),
                content: Text(
                  'Failed to send message',
                  style: GoogleFonts.roboto(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Okay',
                      style: GoogleFonts.roboto(),
                    ),
                  )
                ],
              );
            },
          );
        } else if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  'Error',
                  style: GoogleFonts.roboto(),
                ),
                content: Text(
                  'Failed to send message',
                  style: GoogleFonts.roboto(),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      // Navigate to Login Page
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (ctx) => const LoginAI()),
          (Route<dynamic> route) => false);
    }
  }

  updateTheDBOfSeenMesages(String messageId, String itemId) async {
    if (handler.newUser.user != null) {
      try {
        await handler.fireStore.runTransaction(
          (transaction) async {
            final firestore = handler.fireStore;

            await firestore
                .collection('users')
                .doc(widget.senderId)
                .collection('chats')
                .doc("${widget.recieverId}_$itemId")
                .update({
              'isSeen': true,
            });
            await firestore
                .collection('users')
                .doc(widget.recieverId)
                .collection('chats')
                .doc("${widget.senderId}_$itemId")
                .update({
              'isSeen': true,
            });

            await firestore
                .collection('users')
                .doc(widget.senderId)
                .collection('chats')
                .doc("${widget.recieverId}_$itemId")
                .collection('messages')
                .doc(messageId)
                .update({
              'isSeen': true,
            });
            await firestore
                .collection('users')
                .doc(widget.recieverId)
                .collection('chats')
                .doc("${widget.senderId}_$itemId")
                .collection('messages')
                .doc(messageId)
                .update({
              'isSeen': true,
            });
          },
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (Platform.isAndroid) {
        Navigator.of(
          context,
        ).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const LoginAI()),
            (Route<dynamic> route) => false);
      } else if (Platform.isIOS) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (ctx) => const LoginAI()),
            (Route<dynamic> route) => false);
      }
    }
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  Widget android() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CupertinoColors.black),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.adImageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    return const Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 30,
                        color: CupertinoColors.black,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return const Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 30,
                        color: CupertinoColors.black,
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ios() {
    return const CupertinoPageScaffold(child: SizedBox());
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android();
    }
    if (Platform.isIOS) {
      return ios();
    }
    return const SizedBox();
  }
}
