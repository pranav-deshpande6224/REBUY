import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/UIPart/IOS_Files/screens/home/product_detail_screen.dart';
import 'package:resell/UIPart/IOS_Files/screens/sell/detail_screen.dart';
import 'package:resell/UIPart/Providers/pagination_active_ads/home_ads.dart';
import 'package:resell/constants/constants.dart';

class DisplayHomeAds extends ConsumerStatefulWidget {
  const DisplayHomeAds({super.key});
  @override
  ConsumerState<DisplayHomeAds> createState() => _DisplayHomeAdsState();
}

class _DisplayHomeAdsState extends ConsumerState<DisplayHomeAds> {
  late AuthHandler handler;
  final ScrollController homeAdScrollController = ScrollController();
  final List<SellCategory> categoryList = const [
    SellCategory(
        icon: CupertinoIcons.phone,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: CupertinoIcons.device_laptop,
        categoryTitle: Constants.latopandmonitor,
        subCategory: [
          Constants.laptop,
          Constants.monitor,
          Constants.laptopAccessories
        ]),
    SellCategory(
      icon: Icons.pedal_bike,
      categoryTitle: Constants.cycleandAccessory,
      subCategory: [Constants.cycle, Constants.cycleAccesory],
    ),
    SellCategory(
      icon: CupertinoIcons.building_2_fill,
      categoryTitle: Constants.hostelAccesories,
      subCategory: [
        Constants.whiteBoard,
        Constants.bedPillowCushions,
        Constants.backPack,
        Constants.bottle,
        Constants.trolley,
        Constants.wheelChair,
        Constants.curtain
      ],
    ),
    SellCategory(
      icon: CupertinoIcons.book,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
        icon: CupertinoIcons.tv,
        categoryTitle: Constants.electronicandAppliances,
        subCategory: [
          Constants.calculator,
          Constants.hddSSD,
          Constants.router,
          Constants.tripod,
          Constants.ironBox,
          Constants.camera
        ]),
    SellCategory(
      icon: CupertinoIcons.person_crop_circle,
      categoryTitle: Constants.fashion,
      subCategory: [
        Constants.mensFashion,
        Constants.womensFashion,
      ],
    ),
  ];

  @override
  void dispose() {
    homeAdScrollController.dispose();
    super.dispose();
  }

  void fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(homeAdsprovider.notifier).fetchInitialItems();
    });
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
    fetchInitialData();
    homeAdScrollController.addListener(() {
      double maxScroll = homeAdScrollController.position.maxScrollExtent;
      double currentScroll = homeAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(homeAdsprovider.notifier).fetchMoreItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return connectivityState.when(
      data: (connectivityResult) {
        if (connectivityResult == ConnectivityResult.none) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.wifi_slash,
                  color: CupertinoColors.activeBlue,
                  size: 40,
                ),
                Text(
                  'No Internet Connection',
                  style: GoogleFonts.roboto(),
                ),
                CupertinoButton(
                    child: Text(
                      'Retry',
                      style: GoogleFonts.roboto(),
                    ),
                    onPressed: () async {
                      final x = ref.refresh(connectivityProvider);
                      final y = ref.refresh(internetCheckerProvider);
                      debugPrint(x.toString());
                      debugPrint(y.toString());
                      await ref.read(homeAdsprovider.notifier).refreshItems();
                    })
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
                      Icon(
                        CupertinoIcons.wifi_slash,
                        color: CupertinoColors.activeBlue,
                        size: 40,
                      ),
                      Text(
                        'No Internet Connection',
                        style: GoogleFonts.roboto(),
                      ),
                      CupertinoButton(
                        child: Text(
                          'Retry',
                          style: GoogleFonts.roboto(),
                        ),
                        onPressed: () async {
                          final x = ref.refresh(connectivityProvider);
                          final y = ref.refresh(internetCheckerProvider);
                          debugPrint(x.toString());
                          debugPrint(y.toString());
                          await ref
                              .read(homeAdsprovider.notifier)
                              .refreshItems();
                        },
                      )
                    ],
                  ),
                );
              } else {
                final homeItemState = ref.watch(homeAdsprovider);
                return homeItemState.when(
                  data: (homeState) {
                    if (homeState.items.isEmpty) {
                      return CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: homeAdScrollController,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              ref.read(homeAdsprovider.notifier).refreshItems();
                            },
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 10,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Browse Categories',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 15,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: AspectRatio(
                              aspectRatio: 3.5,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: SizedBox(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categoryList.length,
                                    itemBuilder: (ctx, index) {
                                      final category = categoryList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(
                                            CupertinoPageRoute(
                                              builder: (ctx) => DetailScreen(
                                                categoryName:
                                                    category.categoryTitle,
                                                subCategoryList:
                                                    category.subCategory,
                                                isPostingData: false,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              height: double.infinity,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Icon(
                                                      categoryList[index].icon,
                                                      size: 50,
                                                      color: CupertinoColors
                                                          .activeBlue,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      categoryList[index]
                                                          .categoryTitle,
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Fresh Recomendations',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return CustomScrollView(
                      controller: homeAdScrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          onRefresh: () async {
                            ref.read(homeAdsprovider.notifier).refreshItems();
                          },
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Browse Categories',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 15,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: AspectRatio(
                            aspectRatio: 3.5,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                              ),
                              child: SizedBox(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryList.length,
                                  itemBuilder: (ctx, index) {
                                    final category = categoryList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                          CupertinoPageRoute(
                                            builder: (ctx) => DetailScreen(
                                              categoryName:
                                                  category.categoryTitle,
                                              subCategoryList:
                                                  category.subCategory,
                                              isPostingData: false,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            height: double.infinity,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Icon(
                                                    categoryList[index].icon,
                                                    size: 50,
                                                    color: CupertinoColors
                                                        .activeBlue,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    textAlign: TextAlign.center,
                                                    categoryList[index]
                                                        .categoryTitle,
                                                    style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Fresh Recomendations',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(8),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              childCount: homeState.items.length,
                              (ctx, index) {
                                final ad = homeState.items[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      CupertinoPageRoute(
                                        builder: (ctx) {
                                          return ProductDetailScreen(
                                            documentReference:
                                                ad.documentReference,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: CupertinoColors.systemGrey4,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: CupertinoColors
                                                .systemBackground,
                                            boxShadow: [
                                              BoxShadow(
                                                color: CupertinoColors
                                                    .systemGrey
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              )
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      width: double.infinity,
                                                      imageUrl: ad.images[0],
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return const Icon(
                                                          CupertinoIcons
                                                              .photo_on_rectangle,
                                                          size: 50,
                                                        );
                                                      },
                                                      placeholder:
                                                          (context, url) {
                                                        return Image.asset(
                                                          'assets/images/placeholder.jpg',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                0.08,
                                                              ),
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        '₹ ${ad.price.toInt()}',
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 22,
                                                          color: Colors.green[
                                                              700], // Cool color for price
                                                        ),
                                                      ),
                                                      Text(
                                                        ad.adTitle,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .black87, // Darker color for title
                                                        ),
                                                      ),
                                                      Text(
                                                        ad.postedBy,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Colors
                                                              .black87, // Subtle color for posted-by text
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                          ),
                        ),
                        if (homeState.isLoadingMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CupertinoActivityIndicator(
                                      radius: 15,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Fetching Content...',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  loading: () {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoActivityIndicator(
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
                  },
                );
              }
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: () => Center(child: CupertinoActivityIndicator()),
          );
        }
      },
      error: (error, _) => Center(child: Text('Error: $error')),
      loading: () => Center(child: CupertinoActivityIndicator()),
    );
  }
}
