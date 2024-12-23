import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';
import 'package:resell/UIPart/android_ios/Providers/unread_count.dart';
import 'package:resell/UIPart/android_ios/model/contact.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/chatting_screen_a_i.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BuyingChatsAndroid extends ConsumerStatefulWidget {
  const BuyingChatsAndroid({
    super.key,
  });

  @override
  ConsumerState<BuyingChatsAndroid> createState() => _BuyingChatsState();
}

class _BuyingChatsState extends ConsumerState<BuyingChatsAndroid> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  String getTime(DateTime time) {
    final formattedTime = DateFormat('hh:mm a').format(time);
    return formattedTime;
  }

  Future<void> deleteConversation(String conversationId) async {
    late BuildContext spinner;
    if (handler.newUser.user != null) {
      try {
        showDialog(
            context: context,
            builder: (spinnerContext) {
              spinner = spinnerContext;
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
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
          await batch.commit();
        }
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
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  'Error',
                  style: GoogleFonts.lato(),
                ),
                content: Text(
                  'Something went wrong unable to delete',
                  style: GoogleFonts.lato(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Okay',
                      style: GoogleFonts.lato(),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      // MOVE TO LOGIN
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const LoginAI()),
          (Route<dynamic> route) => false);
    }
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

  Stream<List<Contact>> getContactsBuying() {
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
  }

  void scrollToTarget(List<Contact> contacts) async {
    final data = ref.read(chatNotificationProvider);
    String? adId = data['adId'] ?? null;
    if (adId != null) {
      final index = contacts.indexWhere((contact) => contact.adId == adId);
      if (index != -1) {
        await _itemScrollController.scrollTo(
          index: index,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          final contact = contacts[index];
          ref.read(chatNotificationProvider.notifier).clearNotificationData();
          adId = null;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ChattingScreenAI(
                name: contact.nameOfContact,
                recieverId: contact.contactId,
                senderId: handler.newUser.user!.uid,
                documentReference: contact.reference,
                adImageUrl: contact.adImage,
                adTitle: contact.adTitle,
                adId: contact.adId,
                price: contact.adPrice,
              ),
            ),
          );
        });
      }
    }
  }

  Widget retryAgain() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Something went wrong',
            style: GoogleFonts.lato(),
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () async {
              final _ = await ref.refresh(connectivityProvider.future);
              final x = ref.refresh(internetCheckerProvider.future);
              debugPrint(x.toString());
            },
            child: Text(
              'Retry',
              style: GoogleFonts.lato(
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return SafeArea(
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
                      final notificationData =
                          ref.watch(chatNotificationProvider);
                      return StreamBuilder(
                        stream: getContactsBuying(),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return retryAgain();
                          }
                          final contacts = snapshot.data ?? [];

                          if (notificationData['adId'] != null &&
                              contacts.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              scrollToTarget(contacts);
                            });
                          }
                          return contacts.isEmpty
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
                                        'No Buying Chats',
                                        style: GoogleFonts.lato(
                                            color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ScrollablePositionedList.separated(
                                    itemScrollController: _itemScrollController,
                                    itemBuilder: (ctx, index) {
                                      final obj = snapshot.data![index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (ctx) =>
                                                  ChattingScreenAI(
                                                name: obj.nameOfContact,
                                                recieverId: obj.contactId,
                                                senderId:
                                                    handler.newUser.user!.uid,
                                                documentReference:
                                                    obj.reference,
                                                adImageUrl: obj.adImage,
                                                adTitle: obj.adTitle,
                                                adId: obj.adId,
                                                price: obj.adPrice,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Slidable(
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              SlidableAction(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete,
                                                label: 'Delete',
                                                onPressed: (ctx) {
                                                  showDialog(
                                                    context: ctx,
                                                    barrierDismissible: false,
                                                    builder: (dialogContext) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Alert!'),
                                                        content: const Text(
                                                          'Are you sure you want to delete this chat?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  dialogContext);
                                                            },
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  dialogContext);
                                                              deleteConversation(
                                                                  obj.id);
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            selectedTileColor: Colors.grey[300],
                                            leading: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: obj.adImage,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.photo,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.photo,
                                                    size: 30,
                                                  ),
                                                ),
                                                width:
                                                    60, // Set the desired width and height
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            title: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  obj.nameOfContact,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  obj.adTitle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Colors.blue,
                                                  ),
                                                )
                                              ],
                                            ),
                                            subtitle: obj.lastMessageId ==
                                                    handler.newUser.user!.uid
                                                ? Row(
                                                    children: [
                                                      Icon(
                                                        Icons.done_all,
                                                        color: obj.isSeen
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          obj.lastMessage,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Text(
                                                    obj.lastMessage,
                                                    maxLines: 1,
                                                    style: GoogleFonts.lato(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                            trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  getTime(obj.timeSent),
                                                  style: GoogleFonts.lato(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                StreamBuilder(
                                                  stream: getUnreadCount(
                                                      obj.id, obj.contactId),
                                                  builder: (ctx, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const SizedBox
                                                          .shrink();
                                                    }
                                                    if (snapshot.hasError) {
                                                      return const SizedBox
                                                          .shrink();
                                                    }
                                                    if (snapshot.data! == 0) {
                                                      return const SizedBox
                                                          .shrink();
                                                    } else {
                                                      String displayCount;
                                                      double circleSize;
                                                      if (snapshot.data! <=
                                                          99) {
                                                        displayCount = snapshot
                                                            .data!
                                                            .toString();
                                                        circleSize = 25;
                                                      } else {
                                                        displayCount = snapshot
                                                                    .data! >
                                                                99
                                                            ? (snapshot.data! >
                                                                    999
                                                                ? '999+'
                                                                : '99+')
                                                            : snapshot.data!
                                                                .toString();
                                                        circleSize =
                                                            snapshot.data! > 999
                                                                ? 40
                                                                : 35;
                                                      }
                                                      return Container(
                                                        width: circleSize,
                                                        height: circleSize,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          displayCount,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: snapshot
                                                                        .data! >
                                                                    999
                                                                ? 16
                                                                : snapshot.data! >
                                                                        99
                                                                    ? 14
                                                                    : 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (ctx, inddex) {
                                      return const Divider(
                                        color: Colors.black,
                                        height: 0.5,
                                      );
                                    },
                                    itemCount: snapshot.data!.length,
                                  ),
                                );
                        },
                      );
                    }
                  },
                  loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      ),
                  error: (error, stackTrace) => retryAgain());
            }
          },
          loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
          error: (error, stackTrace) => retryAgain()),
    );
  }
}
