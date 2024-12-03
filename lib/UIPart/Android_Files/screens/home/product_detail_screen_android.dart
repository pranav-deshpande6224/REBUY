import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/Android_Files/screens/chats/chatting_screen_android.dart';
import 'package:resell/UIPart/Android_Files/screens/home/image_detail_screen_android.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class ProductDetailScreenAndroid extends ConsumerStatefulWidget {
  final DocumentReference<Map<String, dynamic>> reference;
  const ProductDetailScreenAndroid({required this.reference, super.key});

  @override
  ConsumerState<ProductDetailScreenAndroid> createState() =>
      _ProductDetailScreenAndroidState();
}

class _ProductDetailScreenAndroidState
    extends ConsumerState<ProductDetailScreenAndroid> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  String getDate(Timestamp timeStamp) {
    DateTime dateTime = timeStamp.toDate();
    return DateFormat('dd-MM-yyyy').format(dateTime);
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
              color: Colors.blue,
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
              color: Colors.blue,
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
              color: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () async {
                        final _ =
                            await ref.refresh(connectivityProvider.future);
                        final x = ref.refresh(internetCheckerProvider.future);
                        debugPrint(x.toString());
                      },
                      child: Text(
                        'Retry',
                        style: GoogleFonts.roboto(),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return internetState.when(
                data: (bool internet) {
                  if (!internet) {
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
                              style: GoogleFonts.roboto(),
                            ),
                            onPressed: () async {
                              final x =
                                  ref.refresh(connectivityProvider.future);
                              final _ =
                                  ref.refresh(internetCheckerProvider.future);
                              debugPrint(x.toString());
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    return StreamBuilder(
                      stream: widget.reference.snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
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
                        if (snapshot.hasError) {
                          // TODO need to handle this error case
                          return const Center(
                            child: Text("Something went wrong"),
                          );
                        }
                        Timestamp? timeStamp =
                            snapshot.data!.data()!['createdAt'];
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
                                  padding: const EdgeInsets.only(
                                      top: 15, left: 8, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              fullscreenDialog: true,
                                              builder: (ctx) =>
                                                  ImageDetailScreenAndroid(
                                                images: item.images,
                                              ),
                                            ),
                                          );
                                        },
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: CarouselSlider(
                                            items: item.images.map(
                                              (e) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white38,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: e,
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (context, url) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.photo,
                                                              size: 30,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          );
                                                        },
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.photo,
                                                              size: 30,
                                                              color:
                                                                  Colors.black,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            handler.newUser.user!.uid ==
                                                    item.userid
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: item.isAvailable
                                              ? () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .push(
                                                    MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          ChattingScreenAndroid(
                                                        name: item.postedBy,
                                                        documentReference:
                                                            widget.reference,
                                                        recieverId: item.userid,
                                                        senderId: handler
                                                            .newUser.user!.uid,
                                                        adImageUrl:
                                                            item.images[0],
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
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            item.isAvailable
                                                ? 'Chat Now'
                                                : "SOLD OUT",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                    );
                  }
                },
                error: (error, _) => Center(child: Text('Error: $error')),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              );
            }
          },
          error: (error, _) => Center(child: Text('Error: $error')),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
