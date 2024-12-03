import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/chatting_screen_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/image_detail_screen_a_i.dart';

class ProductDetailScreenAI extends ConsumerStatefulWidget {
  final DocumentReference<Map<String, dynamic>> documentReference;
  const ProductDetailScreenAI({
    required this.documentReference,
    super.key,
  });

  @override
  ConsumerState<ProductDetailScreenAI> createState() =>
      _ProductDetailScreenAIState();
}

class _ProductDetailScreenAIState extends ConsumerState<ProductDetailScreenAI> {
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  Widget progressIndicator() {
    if (Platform.isAndroid) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    } else if (Platform.isIOS) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }
    return const SizedBox();
  }

  Widget netIssue() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Platform.isAndroid
                ? Icons.wifi_off
                : Platform.isIOS
                    ? CupertinoIcons.wifi_slash
                    : null,
            color: Platform.isAndroid
                ? Colors.blue
                : Platform.isIOS
                    ? CupertinoColors.activeBlue
                    : null,
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
                color: Platform.isAndroid
                    ? Colors.blue
                    : Platform.isIOS
                        ? CupertinoColors.activeBlue
                        : null,
              ),
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

  Widget getExtraDetails(Item item) {
    if (item.brand != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Brand',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.activeBlue,
            ),
          ),
          Text(
            item.brand,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    if (item.tabletType != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tablet',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.activeBlue,
            ),
          ),
          Text(
            item.tabletType,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    if (item.chargerType != '') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charger',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: CupertinoColors.activeBlue,
            ),
          ),
          Text(
            item.chargerType,
            style: GoogleFonts.roboto(fontSize: 22),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Center loading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Platform.isAndroid
              ? const CircularProgressIndicator(
                  color: Colors.blue,
                )
              : Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const SizedBox(),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Loading...',
            style: GoogleFonts.roboto(),
          )
        ],
      ),
    );
  }

  Widget android() {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: Text(
          'Product Details',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: SafeArea(
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
                    return StreamBuilder(
                      stream: widget.documentReference.snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return loading();
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return data(snapshot);
                      },
                    );
                  }
                },
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
                loading: progressIndicator,
              );
            }
          },
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
          loading: progressIndicator,
        ),
      ),
    );
  }

  Widget ios() {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Product Details',
          style: GoogleFonts.roboto(),
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
                    return StreamBuilder(
                      stream: widget.documentReference.snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return loading();
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return data(snapshot);
                      },
                    );
                  }
                },
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
                loading: progressIndicator,
              );
            }
          },
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
          loading: progressIndicator,
        ),
      ),
    );
  }

  Widget data(AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    Timestamp? timeStamp = snapshot.data!.data()!['createdAt'];
    timeStamp ??= Timestamp.fromMicrosecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    final item = Item.fromJson(
      snapshot.data!.data()!,
      snapshot.data!,
      snapshot.data!.reference,
    );

    return Column(
      children: [
        Expanded(
          flex: 9,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Platform.isAndroid) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (ctx) => ImageDetailScreenAI(
                              images: item.images,
                            ),
                          ),
                        );
                      } else if (Platform.isIOS) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (ctx) => ImageDetailScreenAI(
                              images: item.images,
                            ),
                          ),
                        );
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CarouselSlider(
                        items: item.images.map(
                          (e) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemBackground,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: e,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) {
                                      return Center(
                                        child: Icon(
                                          Platform.isAndroid
                                              ? Icons.photo
                                              : Platform.isIOS
                                                  ? CupertinoIcons.photo
                                                  : null,
                                          size: 30,
                                          color: CupertinoColors.black,
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      return Center(
                                        child: Icon(
                                          Platform.isAndroid
                                              ? Icons.photo
                                              : Platform.isIOS
                                                  ? CupertinoIcons.photo
                                                  : null,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        options: CarouselOptions(
                          disableCenter: true,
                          autoPlay: true,
                          enableInfiniteScroll: false,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '₹ ${item.price.toInt()}',
                    style: GoogleFonts.roboto(
                      color: Colors.green[700],
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    item.adTitle,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Description',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    item.adDescription,
                    style: GoogleFonts.roboto(fontSize: 22),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  getExtraDetails(item),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posted By',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        handler.newUser.user!.uid == item.userid
                            ? 'You'
                            : item.postedBy,
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posted At',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        getDate(item.timestamp),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        handler.newUser.user!.uid == item.userid
            ? const SizedBox()
            : Expanded(
                flex: 1,
                child: chatNowButton(item),
              )
      ],
    );
  }

  Widget chatNowButton(Item item) {
    if (Platform.isAndroid) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: item.isAvailable
                ? () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (ctx) => ChattingScreenAI(
                          name: item.postedBy,
                          documentReference: widget.documentReference,
                          recieverId: item.userid,
                          senderId: handler.newUser.user!.uid,
                          adImageUrl: item.images[0],
                          adTitle: item.adTitle,
                          adId: item.id,
                          price: item.price,
                        ),
                      ),
                    );
                  }
                : null,
            child: Text(
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: item.isAvailable ? Colors.white : Colors.grey,
              ),
              item.isAvailable ? 'Chat Now' : "SOLD OUT",
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: CupertinoButton(
            color: CupertinoColors.activeBlue,
            onPressed: item.isAvailable
                ? () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (ctx) => ChattingScreenAI(
                          name: item.postedBy,
                          documentReference: widget.documentReference,
                          recieverId: item.userid,
                          senderId: handler.newUser.user!.uid,
                          adImageUrl: item.images[0],
                          adTitle: item.adTitle,
                          adId: item.id,
                          price: item.price,
                        ),
                      ),
                    );
                  }
                : null,
            child: Text(
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: item.isAvailable
                    ? CupertinoColors.white
                    : CupertinoColors.black,
              ),
              item.isAvailable ? 'Chat Now' : "SOLD OUT",
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  String getDate(Timestamp timeStamp) {
    DateTime dateTime = timeStamp.toDate();
    return DateFormat('dd-MM-yyyy').format(dateTime);
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
