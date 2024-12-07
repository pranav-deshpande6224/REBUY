import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/home/product_detail_screen_android.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/category_ads_pagination.dart';

class DisplayCategoryAdsAndroid extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;
  const DisplayCategoryAdsAndroid({
    required this.categoryName,
    required this.subCategoryName,
    super.key,
  });

  @override
  ConsumerState<DisplayCategoryAdsAndroid> createState() =>
      _DisplayCategoryAdsAndroidState();
}

class _DisplayCategoryAdsAndroidState
    extends ConsumerState<DisplayCategoryAdsAndroid> {
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

  String getDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    String formattedDate =
        DateFormat('dd-MM-yy').format(dateTime); // Format DateTime
    return formattedDate;
  }

  @override
  void dispose() {
    categoryAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(showCatAdsProvider.notifier).resetState();
      },
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
                      style: GoogleFonts.roboto(color: Colors.blue),
                    ),
                    onPressed: () async {
                      final x = ref.refresh(connectivityProvider);
                      final y = ref.refresh(internetCheckerProvider);
                      debugPrint(x.toString());
                      debugPrint(y.toString());
                      await ref.read(showCatAdsProvider.notifier).refreshItems(
                          widget.categoryName, widget.subCategoryName);
                    },
                  )
                ],
              ),
            );
          } else {
            return internetState.when(
              data: (hasInternet) {
                if (!hasInternet) {
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
                              style: GoogleFonts.roboto(color: Colors.blue),
                            ),
                            onPressed: () async {
                              final x = ref.refresh(connectivityProvider);
                              final y = ref.refresh(internetCheckerProvider);
                              debugPrint(x.toString());
                              debugPrint(y.toString());
                              await ref
                                  .read(showCatAdsProvider.notifier)
                                  .refreshItems(widget.categoryName,
                                      widget.subCategoryName);
                            })
                      ],
                    ),
                  );
                } else {
                  final catItemState = ref.watch(showCatAdsProvider);
                  return catItemState.when(
                    data: (catAdState) {
                      return RefreshIndicator(
                        color: Colors.blue,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: categoryAdScrollController,
                          slivers: [
                            catAdState.items.isEmpty
                                ? SliverFillRemaining(
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
                                            'No Ads Found',
                                            style: GoogleFonts.roboto(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        childCount: catAdState.items.length,
                                        (context, index) {
                                          final catAd = catAdState.items[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (ctx) {
                                                    return ProductDetailScreenAndroid(
                                                      reference: catAd
                                                          .documentReference,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: CachedNetworkImage(
                                                      imageUrl: catAd.images[0],
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) {
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.blue,
                                                          ),
                                                        );
                                                      },
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return const Center(
                                                          child: Icon(
                                                            Icons.photo,
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '₹ ${catAd.price}',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: Colors
                                                                .green[700],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          catAd.adTitle,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.person,
                                                              size: 16,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              catAd.postedBy,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          getDate(
                                                              catAd.timestamp),
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black87,
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
                                  ),
                            if (catAdState.isLoadingMore)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
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
                              )
                          ],
                        ),
                        onRefresh: () async {
                          await ref
                              .read(showCatAdsProvider.notifier)
                              .refreshItems(
                                widget.categoryName,
                                widget.subCategoryName,
                              );
                        },
                      );
                    },
                    loading: () {
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
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return Center(child: Text('Error: $error'));
                    },
                  );
                }
              },
              error: (error, _) => Center(child: Text('Error: $error')),
              loading: () => const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              )),
            );
          }
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        )),
      ),
    );
  }
}
