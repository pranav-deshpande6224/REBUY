import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/favourite_ads_pagination.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/product_detail_screen_a_i.dart';

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  late AuthHandler handler;
  final ScrollController favouriteAdScrollController = ScrollController();

  @override
  void dispose() {
    favouriteAdScrollController.dispose();
    super.dispose();
  }

  void fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(favouriteAdsProvider.notifier).fetchInitialItems();
    });
  }

  void moveToLogin() {
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

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    if (handler.newUser.user == null) {
      moveToLogin();
      return;
    }
    fetchInitialData();
    favouriteAdScrollController.addListener(
      () {
        double maxScroll = favouriteAdScrollController.position.maxScrollExtent;
        double currentScroll = favouriteAdScrollController.position.pixels;
        double delta = MediaQuery.of(context).size.width * 0.20;
        if (maxScroll - currentScroll <= delta) {
          ref.read(favouriteAdsProvider.notifier).fetchMoreItems();
        }
      },
    );
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
              final x = ref.refresh(connectivityProvider);
              final y = ref.refresh(internetCheckerProvider);
              debugPrint(x.toString());
              debugPrint(y.toString());
              await ref.read(favouriteAdsProvider.notifier).refreshItems();
            },
          )
        ],
      ),
    );
  }

  Center spinner() {
    if (Platform.isAndroid) {
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
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
    } else if (Platform.isIOS) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(
              radius: 15,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Loading...',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
    }
    return const Center();
  }

  Widget retry() {
    return Center(
      child: Column(
        children: [
          Text('Something went wrong',
              style: GoogleFonts.roboto(color: Colors.blue)),
          const SizedBox(
            height: 10,
          ),
          Platform.isAndroid
              ? TextButton(
                  onPressed: () async {
                    final x = ref.refresh(connectivityProvider);
                    final y = ref.refresh(internetCheckerProvider);
                    debugPrint(x.toString());
                    debugPrint(y.toString());
                    await ref
                        .read(favouriteAdsProvider.notifier)
                        .refreshItems();
                  },
                  child: Text(
                    'Retry',
                    style: GoogleFonts.roboto(color: Colors.blue),
                  ),
                )
              : CupertinoButton(
                  onPressed: () async {
                    final x = ref.refresh(connectivityProvider);
                    final y = ref.refresh(internetCheckerProvider);
                    debugPrint(x.toString());
                    debugPrint(y.toString());
                    await ref
                        .read(favouriteAdsProvider.notifier)
                        .refreshItems();
                  },
                  child: Text(
                    'Retry',
                    style: GoogleFonts.roboto(color: Colors.blue),
                  ),
                )
        ],
      ),
    );
  }

  SliverFillRemaining noFavouriteAd() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/emoji.png',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'No Favourite Ads',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CupertinoSliverRefreshControl cupertinoRefresh() {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        await ref.read(favouriteAdsProvider.notifier).refreshItems();
      },
    );
  }

  String getDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd-MM-yy').format(dateTime);
    return formattedDate;
  }

  Widget dataDisplay(Item ad) {
    return GestureDetector(
      onTap: () {
        if (Platform.isAndroid) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) {
                return ProductDetailScreenAI(
                  documentReference: ad.documentReference,
                );
              },
            ),
          );
        } else if (Platform.isIOS) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (ctx) {
                return ProductDetailScreenAI(
                  documentReference: ad.documentReference,
                );
              },
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: ad.images[0],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Center(
                    child: Platform.isAndroid
                        ? const Icon(
                            Icons.photo,
                            color: Colors.black,
                          )
                        : Platform.isIOS
                            ? const Icon(
                                CupertinoIcons.photo,
                                color: CupertinoColors.black,
                              )
                            : const SizedBox(),
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
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ ${ad.price}',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.adTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Platform.isAndroid
                            ? Icons.person
                            : Platform.isIOS
                                ? CupertinoIcons.person
                                : null,
                        size: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ad.postedBy,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getDate(ad.timestamp),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding havingFavouriteAds(FavouriteAdState adState) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: adState.items.length,
          (context, index) {
            final favAd = adState.items[index];
            return dataDisplay(favAd);
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter fetchingMoreFavouriteAds() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Platform.isAndroid
                  ? const CircularProgressIndicator(
                      color: Colors.blue,
                    )
                  : Platform.isIOS
                      ? const CupertinoActivityIndicator(
                          radius: 16,
                        )
                      : const SizedBox(),
              const SizedBox(height: 10),
              Text(
                'Fetching Content...',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> sliverWidget(FavouriteAdState adState) {
    if (Platform.isAndroid) {
      return [
        adState.items.isEmpty ? noFavouriteAd() : havingFavouriteAds(adState),
        if (adState.isLoadingMore) fetchingMoreFavouriteAds()
      ];
    } else if (Platform.isIOS) {
      return [
        cupertinoRefresh(),
        adState.items.isEmpty ? noFavouriteAd() : havingFavouriteAds(adState),
        if (adState.isLoadingMore) fetchingMoreFavouriteAds()
      ];
    }
    return [];
  }

  CustomScrollView scrollView(FavouriteAdState adState) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: favouriteAdScrollController,
      slivers: sliverWidget(adState),
    );
  }

  Widget android() {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.grey[200],
        title: Text(
          'Your Favourites',
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
                      final itemState = ref.watch(favouriteAdsProvider);
                      return itemState.when(
                          data: (adState) {
                            return RefreshIndicator(
                              color: Colors.blue,
                              child: scrollView(adState),
                              onRefresh: () async {
                                await ref
                                    .read(favouriteAdsProvider.notifier)
                                    .refreshItems();
                              },
                            );
                          },
                          error: (error, stack) => retry(),
                          loading: progressIndicator);
                    }
                  },
                  error: (error, _) => retry(),
                  loading: spinner);
            }
          },
          error: (error, _) => retry(),
          loading: progressIndicator,
        ),
      ),
    );
  }

  Widget ios() {
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          ref.read(favouriteAdsProvider.notifier).resetState();
        },
        child: android(),
      );
    }
    if (Platform.isIOS) {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          ref.read(favouriteAdsProvider.notifier).resetState();
        },
        child: ios(),
      );
    }
    return const SizedBox();
  }
}
