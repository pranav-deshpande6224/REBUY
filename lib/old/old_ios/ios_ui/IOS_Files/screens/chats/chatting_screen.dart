import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:resell/old/old_ios/ios_auth/IOS_Files/Screens/auth/login_ios.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/contact.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';
import 'package:resell/UIPart/android_ios/model/message.dart';
import 'package:resell/old/old_ios/ios_ui/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:resell/UIPart/android_ios/widgets/chat_bubble.dart';
import 'package:resell/UIPart/android_ios/widgets/message_reply_preview.dart';
import 'package:resell/UIPart/android_ios/Providers/active_inactive_send.dart';
import 'package:resell/UIPart/android_ios/Providers/message_reply_provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:uuid/uuid.dart';

class ChattingScreen extends ConsumerStatefulWidget {
  final String name;
  final String adImageUrl;
  final String adTitle;
  final String adId;
  final double price;
  final String recieverId;
  final String senderId;
  final DocumentReference<Map<String, dynamic>> documentReference;
  const ChattingScreen({
    required this.name,
    required this.recieverId,
    required this.senderId,
    required this.documentReference,
    required this.adImageUrl,
    required this.adTitle,
    required this.adId,
    required this.price,
    super.key,
  });

  @override
  ConsumerState<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends ConsumerState<ChattingScreen> {
  final chatController = TextEditingController();
  final chatFocusNode = FocusNode();
  final messageController = ScrollController();
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

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

  String _formatLastSeen(int millisecondsSinceEpoch) {
    final DateTime now = DateTime.now();
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

    final DateFormat timeFormat =
        DateFormat('h:mm a'); // e.g., 12:30 AM, 1:00 PM
    final String formattedTime = timeFormat.format(dateTime);

    final Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Same day
      return 'last seen today at $formattedTime';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'last seen yesterday at $formattedTime';
    } else if (difference.inDays < 7) {
      // Within the last week
      final String weekday =
          DateFormat.EEEE().format(dateTime); // e.g., Monday, Tuesday
      return 'last seen on $weekday at $formattedTime';
    } else {
      // More than a week ago, display date and time
      final DateFormat dateFormat = DateFormat('yMMMd'); // e.g., Oct 24, 2024
      return 'last seen on ${dateFormat.format(dateTime)} at $formattedTime';
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatController.dispose();
    chatFocusNode.dispose();
    messageController.dispose();
  }

  Future<void> sendMessageToDb(
      String message, Item item, MessageReply? messageReply) async {
    chatController.text = '';
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
                    recieverId_adId: '',
                    postedBy: '',
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
                    recieverId_adId: '',
                    postedBy: '',
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
        messageController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to send message'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Navigate to Login Page
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (ctx) => const LoginIos()),
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
      // Navigate to Login Page
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (ctx) => const LoginIos()),
          (Route<dynamic> route) => false);
    }
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      middle: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: CachedNetworkImage(
              imageUrl: widget.adImageUrl,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: Icon(
                  CupertinoIcons.photo,
                  size: 30,
                  color: CupertinoColors.black,
                ),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  CupertinoIcons.photo,
                  size: 30,
                  color: CupertinoColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(),
                ),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.recieverId)
                      .snapshots(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (snapshot.hasError) {
                      return const SizedBox();
                    }
                    final data = snapshot.data!.data();
                    final isOnline = data!['online'] as bool;
                    final lastSeen = data['lastSeen'] as int;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb_fill,
                          color: isOnline
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemYellow,
                        ),
                        Text(
                          isOnline ? 'online' : _formatLastSeen(lastSeen),
                          style: GoogleFonts.lato(
                              fontSize: 13,
                              color: CupertinoColors.darkBackgroundGray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: _buildNavigationBar(),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          ref.read(messageReplyProvider.notifier).update((state) => null);
        },
        child: StreamBuilder<List<Message>>(
          stream: getMessages(widget.recieverId, widget.adId),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (snapshot.hasError) {
              // this is the error page lets see how to handle it
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            return SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (ctx) => ProductDetailScreen(
                            documentReference: widget.documentReference,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.adTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                '₹ ${widget.price.toInt()}',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        controller: messageController,
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        reverse: true,
                        itemBuilder: (ctx, index) {
                          final message = snapshot.data![index];
                          if (!message.isSeen &&
                              message.receiverId == handler.newUser.user!.uid) {
                            updateTheDBOfSeenMesages(
                                message.messageId, widget.adId);
                          }
                          if (message.senderId == handler.newUser.user!.uid) {
                            return SwipeTo(
                              onRightSwipe: (details) {
                                ref.read(messageReplyProvider.notifier).update(
                                      (state) => MessageReply(
                                          message: message.text, isMe: true),
                                    );
                              },
                              child: ChatBubble(
                                message: message.text,
                                date: message.timeSent,
                                isSender: true,
                                isRead: message.isSeen,
                                repliedText: message.repliedMessage,
                                userName: message.repliedTo,
                              ),
                            );
                          }
                          return SwipeTo(
                            onRightSwipe: (details) {
                              ref.read(messageReplyProvider.notifier).update(
                                    (state) => MessageReply(
                                        message: message.text, isMe: false),
                                  );
                            },
                            child: ChatBubble(
                              message: message.text,
                              date: message.timeSent,
                              isSender: false,
                              isRead: message.isSeen,
                              repliedText: message.repliedMessage,
                              userName: message.repliedTo,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  ModifyChatMessageTextField(
                    documentReference: widget.documentReference,
                    chatController: chatController,
                    chatFocusNode: chatFocusNode,
                    name: widget.name,
                    sendMessageToDb: sendMessageToDb,
                    messageController: messageController,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ModifyChatMessageTextField extends ConsumerWidget {
  final FocusNode chatFocusNode;
  final String name;
  final TextEditingController chatController;
  final DocumentReference<Map<String, dynamic>> documentReference;
  final ScrollController messageController;
  final Future<void> Function(
      String message, Item item, MessageReply? messageReply) sendMessageToDb;
  const ModifyChatMessageTextField({
    required this.name,
    required this.chatFocusNode,
    required this.chatController,
    required this.documentReference,
    required this.sendMessageToDb,
    required this.messageController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: documentReference.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        if (snapshot.hasError) {
          // this is the error page lets see how to handle it
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        Timestamp? timeStamp = snapshot.data!.data()!['createdAt'];
        timeStamp ??= Timestamp.fromMicrosecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch);
        final item = Item.fromJson(
          snapshot.data!.data()!,
          snapshot.data!,
          snapshot.data!.reference,
        );
        return item.isAvailable
            ? Consumer(
                builder: (context, ref, child) {
                  final messageReply = ref.watch(messageReplyProvider);
                  final isShowMessageReply = messageReply != null;
                  return Column(
                    children: [
                      isShowMessageReply
                          ? MessageReplyPreview(
                              recieverName: name,
                            )
                          : const SizedBox(),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CupertinoTextField(
                              enableSuggestions: true,
                              focusNode: chatFocusNode,
                              controller: chatController,
                              onChanged: (value) {
                                if (value.trim().isNotEmpty) {
                                  ref
                                      .read(activeInactiveSendProvider.notifier)
                                      .setActiveInactive(true);
                                } else {
                                  ref
                                      .read(activeInactiveSendProvider.notifier)
                                      .setActiveInactive(false);
                                }
                              },
                              minLines: 1,
                              maxLines: 5,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              placeholder: 'Type a message....',
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final activeInactiveSend =
                                  ref.watch(activeInactiveSendProvider);
                              return CupertinoButton(
                                padding: EdgeInsetsDirectional.zero,
                                onPressed: activeInactiveSend
                                    ? () async {
                                        final internetCheck =
                                            await InternetConnection()
                                                .hasInternetAccess;
                                        if (internetCheck) {
                                          sendMessageToDb(chatController.text,
                                              item, messageReply);
                                        } else {
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (context) =>
                                                CupertinoAlertDialog(
                                              title: const Text(
                                                  'No Internet Connection'),
                                              content: const Text(
                                                'Please check your internet connection and try again.',
                                              ),
                                              actions: [
                                                CupertinoDialogAction(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                child: const Icon(CupertinoIcons.paperplane),
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: CupertinoColors.systemGrey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    child: Center(
                      child: Text(
                        "Item Sold Out....",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
