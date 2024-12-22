import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';
import 'package:resell/UIPart/android_ios/Providers/segmented_control_provider.dart';
import 'package:resell/UIPart/android_ios/model/contact.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/buying_chats_android.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/chatting_screen_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/selling_chats_android.dart';

class ChatsAI extends ConsumerStatefulWidget {
  const ChatsAI({super.key});

  @override
  ConsumerState<ChatsAI> createState() => _ChatsAIState();
}

class _ChatsAIState extends ConsumerState<ChatsAI>
    with SingleTickerProviderStateMixin {
  late AuthHandler handler;
  late TabController _tabController;
  String ads = 'buying';
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    final initialIndex = ref.read(topNavIndexProvider);
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: initialIndex);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget android() {
    ref.listen<int>(topNavIndexProvider, (previous, next) {
      _tabController.animateTo(next);
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.grey[200],
        title: Text(
          'Inbox',
          style: GoogleFonts.lato(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            onTap: (value) {
              ref.read(topNavIndexProvider.notifier).state = value;
            },
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(
                child: Text(
                  'Buying',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              Tab(
                child: Text(
                  'Selling',
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BuyingChatsAndroid(),
                SellingChatsAndroid(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget netIssue() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.blue,
            size: 40,
          ),
          Text(
            'No Internet Connection',
            style: GoogleFonts.lato(),
          ),
          TextButton(
            child: Text(
              'Retry',
              style: GoogleFonts.lato(color: Colors.blue),
            ),
            onPressed: () async {
              final _ = await ref.refresh(connectivityProvider.future);
              final x = ref.refresh(internetCheckerProvider.future);
              debugPrint(x.toString());
            },
          )
        ],
      ),
    );
  }

  Stream<List<Contact>> getContacts(String value) {
    if (value == 'buying') {
      return handler.fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('chats')
          .where('postedByUserId', isNotEqualTo: handler.newUser.user!.uid)
          .orderBy('timeSent', descending: true)
          .snapshots()
          .asyncMap((event) async {
        List<Contact> contacts = [];
        for (var doc in event.docs) {
          var chatContact = Contact.fromJson(doc.data());
          contacts.add(chatContact);
        }
        return contacts;
      });
    } else {
      return handler.fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('chats')
          .where('postedByUserId', isEqualTo: handler.newUser.user!.uid)
          .orderBy('timeSent', descending: true)
          .snapshots()
          .asyncMap((event) async {
        List<Contact> contacts = [];
        for (var doc in event.docs) {
          var chatContact = Contact.fromJson(doc.data());
          contacts.add(chatContact);
        }
        return contacts;
      });
    }
  }

  String getTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (time.isAfter(today)) {
      return DateFormat('hh:mm a').format(time);
    } else if (time.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(time);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    late BuildContext spinner;
    if (handler.newUser.user != null) {
      try {
        showCupertinoDialog(
            context: context,
            builder: (spinnerContext) {
              spinner = spinnerContext;
              return const Center(child: CupertinoActivityIndicator());
            });
        CollectionReference<Map<String, dynamic>> chatMessagesCollectionRef =
            handler.fireStore
                .collection('users')
                .doc(handler.newUser.user!.uid)
                .collection('chats')
                .doc(conversationId)
                .collection('messages');
        while (true) {
          QuerySnapshot<Map<String, dynamic>> querySnapshot =
              await chatMessagesCollectionRef.limit(500).get();
          List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
              querySnapshot.docs;
          if (documents.isEmpty) {
            break;
          }
          final batch = handler.fireStore.batch();
          for (var doc in documents) {
            batch.delete(doc.reference);
          }
          // Commit the batch deletion
          await batch.commit();
        }
        // Now delete the last conversation document from the collection
        DocumentSnapshot<Map<String, dynamic>> querySnapshot = await handler
            .fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('chats')
            .doc(conversationId)
            .get();
        await querySnapshot.reference.delete();
        if (!spinner.mounted) return;
        Navigator.of(spinner).pop();
      } catch (e) {
        Navigator.of(spinner).pop();
        showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: const Text('Error'),
                content: const Text('Something went wrong'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Okay'),
                  ),
                ],
              );
            });
      }
    } else {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (ctx) => const LoginAI()),
          (Route<dynamic> route) => false);
    }
  }

  Widget retryAgain() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Something went wrong',
            style: GoogleFonts.lato(color: Colors.blue),
          ),
          CupertinoButton(
            onPressed: () {
              setState(() {});
            },
            child: Text(
              'Retry',
              style: GoogleFonts.lato(),
            ),
          )
        ],
      ),
    );
  }

  Widget ios() {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Inbox',
          style: GoogleFonts.lato(),
        ),
      ),
      child: SafeArea(
        child: connectivityState.when(
            data: (connectivityResult) {
              if (connectivityResult == ConnectivityResult.none) {
                return netIssue();
              } else {
                return internetState.when(
                    data: (hasInternet) {
                      if (!hasInternet) {
                        return netIssue();
                      } else {
                        return Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Consumer(
                                  builder: (context, ref, child) {
                                    final value =
                                        ref.watch(segmentedControlProvider);
                                    return CupertinoSegmentedControl<String>(
                                      groupValue: value,
                                      children: {
                                        'buying': SizedBox(
                                          width: constraints.maxWidth / 2 - 8,
                                          child: Center(
                                            child: Text(
                                              'Buying',
                                              style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        'selling': SizedBox(
                                          width: constraints.maxWidth / 2 - 8,
                                          child: Center(
                                            child: Text(
                                              'Selling',
                                              style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      },
                                      onValueChanged: (value) {
                                        ref
                                            .read(segmentedControlProvider
                                                .notifier)
                                            .changeSegment(value);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Consumer(
                              builder: (ctx, ref, child) {
                                final value =
                                    ref.watch(segmentedControlProvider);
                                return StreamBuilder<List<Contact>>(
                                  stream: getContacts(value),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CupertinoActivityIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return retryAgain();
                                    }
                                    return Expanded(
                                      child: snapshot.data!.isEmpty
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/emoji.png',
                                                    height: 80,
                                                    width: 80,
                                                  ),
                                                  Text(
                                                    value == 'buying'
                                                        ? 'No Buying Chats'
                                                        : 'No Selling Chats',
                                                    style: GoogleFonts.lato(),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (ctx, index) {
                                                final obj =
                                                    snapshot.data![index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    height: 83,
                                                    child: Slidable(
                                                      endActionPane: ActionPane(
                                                        motion:
                                                            const ScrollMotion(),
                                                        children: [
                                                          SlidableAction(
                                                            onPressed: (ctx) {
                                                              showCupertinoDialog(
                                                                  context: ctx,
                                                                  builder:
                                                                      (builderContext) {
                                                                    return CupertinoAlertDialog(
                                                                      title: const Text(
                                                                          'Alert!'),
                                                                      content:
                                                                          const Text(
                                                                              'Are you sure you want to delete this chat?'),
                                                                      actions: [
                                                                        CupertinoDialogAction(
                                                                          isDefaultAction:
                                                                              true,
                                                                          child:
                                                                              const Text('Cancel'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(builderContext);
                                                                          },
                                                                        ),
                                                                        CupertinoDialogAction(
                                                                          isDestructiveAction:
                                                                              true,
                                                                          child:
                                                                              const Text(
                                                                            "Delete",
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(builderContext);
                                                                            deleteConversation(obj.id);
                                                                          },
                                                                        )
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            backgroundColor:
                                                                CupertinoColors
                                                                    .systemRed,
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons.delete,
                                                            label: 'Delete',
                                                          )
                                                        ],
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .push(
                                                            CupertinoPageRoute(
                                                              builder: (ctx) =>
                                                                  ChattingScreenAI(
                                                                name: obj
                                                                    .nameOfContact,
                                                                recieverId: obj
                                                                    .contactId,
                                                                senderId:
                                                                    handler
                                                                        .newUser
                                                                        .user!
                                                                        .uid,
                                                                documentReference:
                                                                    obj.reference,
                                                                adImageUrl:
                                                                    obj.adImage,
                                                                adTitle:
                                                                    obj.adTitle,
                                                                price:
                                                                    obj.adPrice,
                                                                adId: obj.adId,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 73,
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    height: 60,
                                                                    width: 60,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border: Border.all(
                                                                          color:
                                                                              CupertinoColors.black),
                                                                    ),
                                                                    child:
                                                                        ClipOval(
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        imageUrl:
                                                                            obj.adImage,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        placeholder:
                                                                            (context,
                                                                                url) {
                                                                          return const Center(
                                                                            child:
                                                                                Icon(
                                                                              CupertinoIcons.photo,
                                                                              size: 30,
                                                                              color: CupertinoColors.black,
                                                                            ),
                                                                          );
                                                                        },
                                                                        errorWidget: (context,
                                                                            url,
                                                                            error) {
                                                                          return const Center(
                                                                            child:
                                                                                Icon(
                                                                              CupertinoIcons.photo,
                                                                              size: 30,
                                                                              color: CupertinoColors.black,
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          bottom:
                                                                              BorderSide(
                                                                            width:
                                                                                0.5,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  obj.nameOfContact,
                                                                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 8),
                                                                                child: Text(
                                                                                  getTime(obj.timeSent),
                                                                                  style: GoogleFonts.lato(fontWeight: FontWeight.w500),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            obj.adTitle,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                GoogleFonts.roboto(
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                8,
                                                                          ),
                                                                          obj.lastMessageId == handler.newUser.user!.uid
                                                                              ? Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.done_all,
                                                                                      color: obj.isSeen ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        obj.lastMessage,
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                )
                                                                              : Expanded(
                                                                                  child: Text(
                                                                                    obj.lastMessage,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        );
                      }
                    },
                    loading: () => const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                    error: (error, stackTrace) => retryAgain());
              }
            },
            loading: () => const Center(
                  child: CupertinoActivityIndicator(),
                ),
            error: (error, stackTrace) => retryAgain()),
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
