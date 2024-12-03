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
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/category_ads_pagination.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/product_detail_screen_a_i.dart';

class DisplayCategoryAdsAI extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;
  const DisplayCategoryAdsAI(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  ConsumerState<DisplayCategoryAdsAI> createState() =>
      _DisplayCategoryAdsAIState();
}

class _DisplayCategoryAdsAIState extends ConsumerState<DisplayCategoryAdsAI> {
  late AuthHandler handler;
  final ScrollController categoryAdScrollController = ScrollController();
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showCatAdsProvider.notifier).fetchInitialItems(
            widget.categoryName,
            widget.subCategoryName,
          );
    });
    categoryAdScrollController.addListener(() {
      double maxScroll = categoryAdScrollController.position.maxScrollExtent;
      double currentScroll = categoryAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref
            .read(showCatAdsProvider.notifier)
            .fetchMoreItems(widget.categoryName, widget.subCategoryName);
      }
    });
  }

  @override
  void dispose() {
    categoryAdScrollController.dispose();
    super.dispose();
  }

  String getDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate =
        DateFormat('dd-MM-yy').format(dateTime); // Format DateTime
    return formattedDate;
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
              await ref.read(showCatAdsProvider.notifier).refreshItems(
                    widget.categoryName,
                    widget.subCategoryName,
                  );
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

  SliverFillRemaining noAds() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/emoji.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'No Ads Found',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> noCatAdSliver() {
    if (Platform.isAndroid) {
      return [noAds()];
    } else if (Platform.isIOS) {
      return [refreshIos(), noAds()];
    }
    return [];
  }

  SliverToBoxAdapter fetchMoreAdsLoader() {
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
                          radius: 15,
                        )
                      : const SizedBox(),
              const SizedBox(height: 10),
              Text(
                'Fetching Content...',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> havingCatAdSliver(CategoryAdsState catAdState) {
    if (Platform.isAndroid) {
      return [
        catData(catAdState),
        if (catAdState.isLoadingMore) fetchMoreAdsLoader()
      ];
    } else if (Platform.isIOS) {
      return [
        refreshIos(),
        catData(catAdState),
        if (catAdState.isLoadingMore) fetchMoreAdsLoader()
      ];
    }
    return [];
  }

  SliverPadding catData(CategoryAdsState data) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: data.items.length,
          (context, index) {
            final catAd = data.items[index];
            return GestureDetector(
              onTap: () {
                if (Platform.isAndroid) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) {
                        return ProductDetailScreenAI(
                          documentReference: catAd.documentReference,
                        );
                      },
                    ),
                  );
                } else if (Platform.isIOS) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (ctx) {
                        return ProductDetailScreenAI(
                          documentReference: catAd.documentReference,
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
                        imageUrl: catAd.images[0],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Center(
                            child: Platform.isAndroid
                                ? const CircularProgressIndicator(
                                    color: Colors.blue,
                                  )
                                : Platform.isIOS
                                    ? const CupertinoActivityIndicator()
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
                            '₹ ${catAd.price}',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            catAd.adTitle,
                            maxLines: 2,
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
                                catAd.postedBy,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getDate(catAd.timestamp),
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
          },
        ),
      ),
    );
  }

  CustomScrollView scrollView(CategoryAdsState catAdState) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: categoryAdScrollController,
      slivers: catAdState.items.isEmpty
          ? noCatAdSliver()
          : havingCatAdSliver(catAdState),
    );
  }

  CupertinoSliverRefreshControl refreshIos() {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        await ref.read(showCatAdsProvider.notifier).refreshItems(
              widget.categoryName,
              widget.subCategoryName,
            );
      },
    );
  }

  Widget android() {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return connectivityState.when(
      data: (connectivityResult) {
        if (connectivityResult == ConnectivityResult.none) {
          return netIssue();
        } else {
          return internetState.when(
            data: (hasInternet) {
              if (!hasInternet) {
                return netIssue();
              } else {
                final catItemState = ref.watch(showCatAdsProvider);
                return catItemState.when(
                  data: (catAdState) {
                    return RefreshIndicator(
                      color: Colors.blue,
                      onRefresh: () async {
                        await ref
                            .read(showCatAdsProvider.notifier)
                            .refreshItems(
                              widget.categoryName,
                              widget.subCategoryName,
                            );
                      },
                      child: scrollView(catAdState),
                    );
                  },
                  error: (error, _) => Center(child: Text('Error: $error')),
                  loading: spinner,
                );
              }
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: progressIndicator,
          );
        }
      },
      error: (error, _) => Center(child: Text('Error: $error')),
      loading: progressIndicator,
    );
  }

  Widget ios() {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return connectivityState.when(
      data: (connectivityResult) {
        if (connectivityResult == ConnectivityResult.none) {
          return netIssue();
        } else {
          return internetState.when(
            data: (hasInternet) {
              if (!hasInternet) {
                return netIssue();
              } else {
                final catItemState = ref.watch(showCatAdsProvider);
                return catItemState.when(
                  data: (catAdState) {
                    return scrollView(catAdState);
                  },
                  error: (error, _) => Center(child: Text('Error: $error')),
                  loading: spinner,
                );
              }
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: progressIndicator,
          );
        }
      },
      error: (error, _) => Center(child: Text('Error: $error')),
      loading: progressIndicator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(showCatAdsProvider.notifier).resetState();
      },
      child: Platform.isAndroid
          ? android()
          : Platform.isIOS
              ? ios()
              : const SizedBox(),
    );
  }
}
