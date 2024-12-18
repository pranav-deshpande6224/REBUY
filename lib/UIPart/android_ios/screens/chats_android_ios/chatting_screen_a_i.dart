import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/Providers/active_inactive_send.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';
import 'package:resell/UIPart/android_ios/Providers/item_object_stream.dart';
import 'package:resell/UIPart/android_ios/Providers/message_reply_provider.dart';
import 'package:resell/UIPart/android_ios/model/contact.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';
import 'package:resell/UIPart/android_ios/model/message.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/product_detail_screen_a_i.dart';
import 'package:resell/UIPart/android_ios/widgets/chat_bubble.dart';
import 'package:resell/UIPart/android_ios/widgets/message_reply_preview.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:uuid/uuid.dart';

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

class _ChattingScreenAIState extends ConsumerState<ChattingScreenAI>
    with SingleTickerProviderStateMixin {
  final chatFocusNode = FocusNode();
  final messageController = ScrollController();
  final player = AudioPlayer();
  late AuthHandler handler;
  late DateTime time;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    time = DateTime.now();
    //  ref.read(activeChatProvider.notifier).state = widget.recieverId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatFocusNode.addListener(() {
        if (chatFocusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 200), () => scrollDown());
        }
      });
      Future.delayed(const Duration(milliseconds: 200), () => scrollDown());
    });
    super.initState();
  }

  Future<void> playRecievingMessageSound() async {
    String path = 'sounds/rec.mp3';
    await player.play(AssetSource(path));
  }

  void scrollDown() {
    if (messageController.hasClients) {
      messageController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatLastSeen(int millisecondsSinceEpoch) {
    final DateTime now = DateTime.now();
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return "Last seen Today ${DateFormat('hh:mm a').format(dateTime)}";
    } else if (dateTime.isAfter(yesterday)) {
      return 'Last seen Yesterday ${DateFormat('hh:mm a').format(dateTime)}';
    } else {
      return 'Last seen ${DateFormat('yyyy-MM-dd').format(dateTime)}';
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    chatFocusNode.dispose();
    player.dispose();
    super.dispose();
  }

  AppBar getAndroidAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 3,
      backgroundColor: Colors.grey[200],
      title: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.adImageUrl,
              placeholder: (context, url) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.photo,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.photo,
                  size: 30,
                ),
              ),
              width: 50, // Set the desired width and height
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
                          Icons.lightbulb,
                          color: isOnline ? Colors.green : Colors.yellow,
                        ),
                        Text(
                          isOnline ? 'online' : _formatLastSeen(lastSeen),
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
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
        if (message.senderId != handler.newUser.user!.uid &&
            (message.timeSent.isAfter(time) ||
                message.timeSent.isAtSameMomentAs(time)) &&
            !message.isSeen) {
          playRecievingMessageSound();
        }
        messages.add(message);
      }
      return messages.reversed.toList();
    });
  }

  Widget detailsAboutProduct() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreenAI(
              documentReference: widget.documentReference,
            ),
          ),
        );
      },
      child: Container(
        height: 40,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.black),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  widget.adTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  '₹ ${widget.price.toInt()}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const LoginAI()),
            (Route<dynamic> route) => false);
      } else if (Platform.isIOS) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (ctx) => const LoginAI()),
            (Route<dynamic> route) => false);
      }
    }
  }

  void showError(String text) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.roboto(),
            ),
            content: Text(text),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Okay',
                  style: GoogleFonts.roboto(),
                ),
              ),
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
            content: Text(text),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Okay',
                  style: GoogleFonts.roboto(),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget android() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getAndroidAppBar(),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          ref.read(messageReplyProvider.notifier).update((state) => null);
          ref.read(activeChatProvider.notifier).state = null;
        },
        child: StreamBuilder(
          stream: getMessages(widget.recieverId, widget.adId),
          builder: (BuildContext ctx, AsyncSnapshot<List<Message>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
            if (snapshot.hasError) {
              // this is the error page lets see how to handle it
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Something went wrong',
                      style: GoogleFonts.roboto(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text(
                        'Retry',
                        style: GoogleFonts.roboto(),
                      ),
                    )
                  ],
                ),
              );
            }
            return SafeArea(
              child: Column(
                children: [
                  detailsAboutProduct(),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.separated(
                        reverse: true,
                        shrinkWrap: true,
                        controller: messageController,
                        itemBuilder: (ctx, index) {
                          final message = snapshot.data![index];
                          if (!message.isSeen &&
                              message.receiverId == handler.newUser.user!.uid) {
                            updateTheDBOfSeenMesages(
                              message.messageId,
                              widget.adId,
                            );
                          }
                          if (message.senderId == handler.newUser.user!.uid) {
                            return SwipeTo(
                              key: UniqueKey(),
                              onRightSwipe: (details) {
                                ref.read(messageReplyProvider.notifier).update(
                                      (state) => MessageReply(
                                          message: message.text, isMe: true),
                                    );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: ChatBubble(
                                  message: message.text,
                                  date: message.timeSent,
                                  isSender: true,
                                  isRead: message.isSeen,
                                  repliedText: message.repliedMessage,
                                  userName: message.repliedTo,
                                ),
                              ),
                            );
                          }
                          return SwipeTo(
                            key: UniqueKey(),
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
                        separatorBuilder: (ctx, index) {
                          return const SizedBox(
                            height: 5,
                          );
                        },
                        itemCount: snapshot.data!.length,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  textFieldOrContainer(),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget textFieldOrContainer() {
    final itemAsyncValue =
        ref.watch(itemStreamProvider(widget.documentReference));
    return itemAsyncValue.when(
      data: (item) {
        return item.isAvailable
            ? ChatMessageTextField(
                scrollDown: scrollDown,
                documentReference: widget.documentReference,
                chatFocusNode: chatFocusNode,
                name: widget.name,
                senderId: widget.senderId,
                recieverId: widget.recieverId,
                item: item,
                player: player,
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Platform.isAndroid
                        ? Colors.grey[200]
                        : CupertinoColors.systemGrey,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    child: Center(
                      child: Text(
                        "Item Sold Out....",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
      },
      error: (error, stackTrace) => Center(
        child: Platform.isAndroid
            ? TextButton(
                onPressed: () {
                  final _ =
                      ref.refresh(itemStreamProvider(widget.documentReference));
                },
                child: Text(
                  'Retry',
                  style: GoogleFonts.roboto(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : CupertinoButton(
                onPressed: () {
                  final _ = ref.refresh(
                    itemStreamProvider(widget.documentReference),
                  );
                },
                child: Text(
                  'Retry',
                  style: GoogleFonts.roboto(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      middle: Row(
        children: [
          ClipOval(
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
                  style: GoogleFonts.roboto(),
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
                          style: GoogleFonts.roboto(
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

  Widget ios() {
    return CupertinoPageScaffold(
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
              return Center(
                child: Column(
                  children: [
                    Text('Something went wrong', style: GoogleFonts.roboto()),
                    CupertinoButton(
                        child: Text(
                          'Retry',
                          style: GoogleFonts.roboto(),
                        ),
                        onPressed: () {
                          setState(() {});
                        })
                  ],
                ),
              );
            }
            return SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (ctx) => ProductDetailScreenAI(
                            documentReference: widget.documentReference,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1),
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
                                style: GoogleFonts.roboto(),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                '₹ ${widget.price.toInt()}',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.separated(
                        reverse: true,
                        shrinkWrap: true,
                        controller: messageController,
                        itemBuilder: (ctx, index) {
                          final message = snapshot.data![index];
                          if (!message.isSeen &&
                              message.receiverId == handler.newUser.user!.uid) {
                            updateTheDBOfSeenMesages(
                              message.messageId,
                              widget.adId,
                            );
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
                        separatorBuilder: (ctx, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: snapshot.data!.length,
                      ),
                    ),
                  ),
                  textFieldOrContainer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android();
    }
    if (Platform.isIOS) {
      return ios();
    }
    return const Placeholder();
  }
}

class ChatMessageTextField extends ConsumerStatefulWidget {
  final FocusNode chatFocusNode;
  final DocumentReference<Map<String, dynamic>> documentReference;
  final String name;
  final String recieverId;
  final String senderId;
  final Item item;
  final void Function() scrollDown;
  final AudioPlayer player;

  const ChatMessageTextField({
    required this.scrollDown,
    required this.chatFocusNode,
    required this.name,
    required this.item,
    required this.documentReference,
    required this.recieverId,
    required this.senderId,
    required this.player,
    super.key,
  });

  @override
  ConsumerState<ChatMessageTextField> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<ChatMessageTextField> {
  final TextEditingController chatController = TextEditingController();
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  Future<void> playSendMessageSound() async {
    String path = 'sounds/sen.mp3';
    await widget.player.play(AssetSource(path));
  }

  Future<int> fetchUnreadCount(Item item) async {
    DocumentSnapshot<Map<String, dynamic>> data = await handler.fireStore
        .collection('users')
        .doc(widget.recieverId)
        .collection('chats')
        .doc("${widget.senderId}_${item.id}")
        .get();
    if (data.exists) {
      int unreadCount = data['unreadCount'] ?? 0;
      return unreadCount;
    } else {
      return 1;
    }
  }

  Future<void> sendMessageToDb(
      String message, Item item, MessageReply? messageReply) async {
    if (message.isEmpty) {
      return;
    }
    chatController.clear();
    ref.read(messageReplyProvider.notifier).update((state) => null);
    ref.read(activeInactiveSendProvider.notifier).reset();
    final messageId = const Uuid().v1();
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
            await playSendMessageSound();
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

        await callingFbFunction(item, messageId);
        widget.scrollDown();
      } catch (e) {
        print(e.toString());
        if (Platform.isAndroid) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: GoogleFonts.roboto(),
                ),
                content:
                    Text('Failed to send message', style: GoogleFonts.roboto()),
                actions: [
                  TextButton(
                    child: Text('Okay',
                        style: GoogleFonts.roboto(color: Colors.blue)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (Platform.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text('Error', style: GoogleFonts.roboto()),
                content:
                    Text('Failed to send message', style: GoogleFonts.roboto()),
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

  Future<void> callingFbFunction(Item item, String messageId) async {
    if (handler.newUser.user != null) {
      try {
        final functions = FirebaseFunctions.instance;
        await functions.httpsCallable('myFunction').call({
          'chatId': "${widget.senderId}_${item.id}",
          'recipientUid': widget.recieverId,
          'messageId': messageId,
        });
      } catch (e) {
        debugPrint('Error sending message: ${e.toString()}');
      }
    } else {
      debugPrint('user not logged in');
    }
  }

  Widget androidTextField(Item item, MessageReply? messageReply) {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
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
            enableSuggestions: true,
            focusNode: widget.chatFocusNode,
            cursorColor: Colors.blue,
            controller: chatController,
            decoration: InputDecoration(
              hintText: 'Type a message....',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final activeInactiveSend = ref.watch(activeInactiveSendProvider);
            return IconButton(
              onPressed: activeInactiveSend
                  ? () async {
                      final internetCheck =
                          await InternetConnection().hasInternetAccess;
                      if (internetCheck) {
                        sendMessageToDb(
                            chatController.text, item, messageReply);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('No Internet Connection',
                                style: GoogleFonts.roboto()),
                            content: Text(
                                'Please check your internet connection and try again.',
                                style: GoogleFonts.roboto()),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Okay',
                                  style: GoogleFonts.roboto(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  : null,
              icon: const Icon(
                Icons.send,
                color: Colors.blue,
              ),
            );
          },
        )
      ],
    );
  }

  Widget iosTextField(Item item, MessageReply? messageReply) {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: CupertinoTextField(
            enableSuggestions: true,
            focusNode: widget.chatFocusNode,
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
            final activeInactiveSend = ref.watch(activeInactiveSendProvider);
            return CupertinoButton(
              padding: EdgeInsetsDirectional.zero,
              onPressed: activeInactiveSend
                  ? () async {
                      final internetCheck =
                          await InternetConnection().hasInternetAccess;
                      if (internetCheck) {
                        sendMessageToDb(
                            chatController.text.trim(), item, messageReply);
                      } else {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('No Internet Connection',
                                style: GoogleFonts.roboto()),
                            content: Text(
                                'Please check your internet connection and try again.',
                                style: GoogleFonts.roboto()),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Okay',
                                  style: GoogleFonts.roboto(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  : null,
              child: const Icon(
                CupertinoIcons.paperplane,
              ),
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final messageReply = ref.watch(messageReplyProvider);
        final isShowMessageReply = messageReply != null;
        return Column(
          children: [
            isShowMessageReply
                ? MessageReplyPreview(
                    recieverName: widget.name,
                  )
                : const SizedBox(),
            Platform.isAndroid
                ? androidTextField(widget.item, messageReply)
                : iosTextField(widget.item, messageReply),
          ],
        );
      },
    );
  }
}
