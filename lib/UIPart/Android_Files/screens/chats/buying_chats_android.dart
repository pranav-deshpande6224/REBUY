import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/IOS_Files/model/contact.dart';

class BuyingChatsAndroid extends ConsumerStatefulWidget {
  const BuyingChatsAndroid({super.key});

  @override
  ConsumerState<BuyingChatsAndroid> createState() => _BuyingChatsState();
}

class _BuyingChatsState extends ConsumerState<BuyingChatsAndroid> {
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

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return SafeArea(
      child: connectivityState.when(
        data: (connectivityResult) {
          if (connectivityResult == ConnectivityResult.none) {
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
                    style: GoogleFonts.roboto(),
                  ),
                  TextButton(
                    child: Text(
                      'Retry',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () async {
                      // To Do Something
                      final _ = await ref.refresh(connectivityProvider.future);
                      final x = ref.refresh(internetCheckerProvider.future);
                      debugPrint(x.toString());
                    },
                  )
                ],
              ),
            );
          } else {
            return internetState.when(
              data: (hasInternet) {
                if (!hasInternet) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.blue,
                        size: 40,
                      ),
                      Text(
                        'No Internet Connection',
                        style: GoogleFonts.roboto(),
                      ),
                      TextButton(
                        child: Text(
                          'Retry',
                          style: GoogleFonts.roboto(
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () async {
                          // To Do Something
                          final _ =
                              await ref.refresh(connectivityProvider.future);
                          final x = ref.refresh(internetCheckerProvider.future);
                          debugPrint(x.toString());
                        },
                      )
                    ],
                  );
                } else {
                  return StreamBuilder(
                    stream: getContactsBuying(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        //TODO : Handle Error
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }
                      return snapshot.data!.isEmpty
                          ? const Center(
                              child: Text(
                                'No Chats',
                              ),
                            )
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (ctx, index) {
                                final obj = snapshot.data![index];
                                return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 8),
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
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text('Alert!'),
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
                                                            // deleteConversation(
                                                            //     obj.id);
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.red,
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
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 73,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      child: ClipOval(
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: obj.adImage,
                                                          fit: BoxFit.contain,
                                                          placeholder:
                                                              (context, url) {
                                                            return const Center(
                                                              child: Icon(
                                                                Icons.photo,
                                                                size: 30,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                              url, error) {
                                                            return const Center(
                                                              child: Icon(
                                                                Icons.photo,
                                                                size: 30,
                                                                color: Colors
                                                                    .black,
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
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    obj.nameOfContact,
                                                                    style: GoogleFonts.roboto(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8),
                                                                  child: Text(
                                                                    getTime(obj
                                                                        .timeSent),
                                                                    style: GoogleFonts.roboto(
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              obj.adTitle,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            obj.lastMessageId ==
                                                                    handler
                                                                        .newUser
                                                                        .user!
                                                                        .uid
                                                                ? Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .done_all,
                                                                        color: obj.isSeen
                                                                            ? Colors.blue
                                                                            : Colors.grey,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          obj.lastMessage,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )
                                                                : Expanded(
                                                                    child: Text(
                                                                      obj.lastMessage,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                        )));
                              },
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
              error: (error, stackTrace) => const Center(
                child: Text('Error'),
              ),
            );
          }
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
        error: (error, stackTrace) => const Center(
          child: Text('Error'),
        ),
      ),
    );
  }
}
