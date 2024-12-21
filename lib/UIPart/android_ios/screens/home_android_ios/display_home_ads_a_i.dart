import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/home_ads.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/fetch_category_ads_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/product_detail_screen_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/sell_android_ios/detail_screen_a_i.dart';
import 'package:resell/constants/constants.dart';

class DisplayHomeAdsAI extends ConsumerStatefulWidget {
  const DisplayHomeAdsAI({super.key});

  @override
  ConsumerState<DisplayHomeAdsAI> createState() => _DisplayHomeAdsAIState();
}

class _DisplayHomeAdsAIState extends ConsumerState<DisplayHomeAdsAI> {
  late AuthHandler handler;
  final ScrollController homeAdScrollController = ScrollController();
  final List<SellCategory> categoryList = [
    SellCategory(
        icon: Platform.isAndroid
            ? Icons.phone
            : Platform.isIOS
                ? CupertinoIcons.phone
                : Icons.photo,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: Platform.isAndroid
            ? Icons.laptop
            : Platform.isIOS
                ? CupertinoIcons.device_laptop
                : Icons.photo,
        categoryTitle: Constants.latopandmonitor,
        subCategory: [
          Constants.laptop,
          Constants.monitor,
          Constants.laptopAccessories
        ]),
    const SellCategory(
      icon: Icons.pedal_bike,
      categoryTitle: Constants.cycleandAccessory,
      subCategory: [Constants.cycle, Constants.cycleAccesory],
    ),
    SellCategory(
      icon: Platform.isAndroid
          ? Icons.domain
          : Platform.isIOS
              ? CupertinoIcons.building_2_fill
              : Icons.photo,
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
      icon: Platform.isAndroid
          ? Icons.book
          : Platform.isIOS
              ? CupertinoIcons.book
              : Icons.photo,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
        icon: Platform.isAndroid
            ? Icons.tv
            : Platform.isIOS
                ? CupertinoIcons.tv
                : Icons.photo,
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
      icon: Platform.isAndroid
          ? Icons.person_2_rounded
          : Platform.isIOS
              ? CupertinoIcons.person_crop_circle
              : Icons.photo,
      categoryTitle: Constants.fashion,
      subCategory: [
        Constants.mensFashion,
        Constants.womensFashion,
      ],
    ),
    SellCategory(
      icon: Platform.isAndroid
          ? Icons.other_houses
          : Platform.isIOS
              ? CupertinoIcons.folder_open
              : Icons.photo,
      categoryTitle: Constants.other,
      subCategory: [],
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
    homeAdScrollController.addListener(
      () {
        double maxScroll = homeAdScrollController.position.maxScrollExtent;
        double currentScroll = homeAdScrollController.position.pixels;
        double delta = MediaQuery.of(context).size.width * 0.20;
        if (maxScroll - currentScroll <= delta) {
          ref.read(homeAdsprovider.notifier).fetchMoreItems();
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
            style: GoogleFonts.lato(),
          ),
          TextButton(
            child: Text(
              'Retry',
              style: GoogleFonts.lato(
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
              await ref.read(homeAdsprovider.notifier).refreshItems();
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
              style: GoogleFonts.lato(
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
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
    }
    return const Center();
  }

  SliverToBoxAdapter categories() {
    return SliverToBoxAdapter(
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
                if (category.categoryTitle == Constants.other) {
                  return GestureDetector(
                    onTap: () => moveToFetchOtherCategoryAdsAI(category),
                    child: childBody(category),
                  );
                }
                return GestureDetector(
                  onTap: () => moveToDetailScreenAI(category),
                  child: childBody(category),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void moveToFetchOtherCategoryAdsAI(SellCategory category) {
    if (Platform.isAndroid) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => FetchCategoryAdsAI(
            categoryName: category.categoryTitle,
            subCategoryName: '',
          ),
        ),
      );
    } else if (Platform.isIOS) {
      Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (ctx) => FetchCategoryAdsAI(
            categoryName: category.categoryTitle,
            subCategoryName: '',
          ),
        ),
      );
    }
  }

  void moveToDetailScreenAI(SellCategory category) {
    if (Platform.isAndroid) {
      Navigator.of(
        context,
      ).push(
        MaterialPageRoute(
          builder: (ctx) => DetailScreenAI(
            categoryName: category.categoryTitle,
            subCategoryList: category.subCategory,
            isPostingData: false,
          ),
        ),
      );
    } else if (Platform.isIOS) {
      Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (ctx) => DetailScreenAI(
            categoryName: category.categoryTitle,
            subCategoryList: category.subCategory,
            isPostingData: false,
          ),
        ),
      );
    }
  }

  Widget childBody(SellCategory category) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Icon(
                  category.icon,
                  size: 50,
                  color: Platform.isAndroid
                      ? Colors.blue
                      : Platform.isIOS
                          ? CupertinoColors.activeBlue
                          : Colors.blue,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  textAlign: TextAlign.center,
                  category.categoryTitle,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
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
    );
  }

  SliverToBoxAdapter text(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> emptySlivers() {
    if (Platform.isAndroid) {
      return [
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 10,
          ),
        ),
        text('Browse Categories'),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 15,
          ),
        ),
        categories(),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 10,
          ),
        ),
        text('Fresh Recomendations')
      ];
    } else if (Platform.isIOS) {
      return [
        refreshIos(),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 10,
          ),
        ),
        text('Browse Categories'),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 15,
          ),
        ),
        categories(),
        text('Fresh Recomendations')
      ];
    }
    return [];
  }

  SliverPadding gridContent(HomeAdState homeState) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          childCount: homeState.items.length,
          (ctx, index) {
            final ad = homeState.items[index];
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
                  Navigator.of(context, rootNavigator: true).push(
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
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 200, 179, 172),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl: ad.images[0],
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return const Icon(
                                      CupertinoIcons.photo_on_rectangle,
                                      size: 50,
                                    );
                                  },
                                  placeholder: (context, url) {
                                    return Image.asset(
                                      'assets/images/placeholder.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
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
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '₹ ${ad.price.toInt()}',
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.green[500],
                                    ),
                                  ),
                                  Text(
                                    ad.brand.isNotEmpty ? ad.brand : ad.adTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    ad.postedBy,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.brown[400],
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
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: Platform.isAndroid
              ? 0.72
              : Platform.isIOS
                  ? 0.75
                  : 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
      ),
    );
  }

  SliverToBoxAdapter fetchingMoreHomeAds() {
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
                style: GoogleFonts.lato(
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

  List<Widget> slivers(HomeAdState homeState) {
    return [
      Platform.isIOS
          ? refreshIos()
          : Platform.isAndroid
              ? const SliverToBoxAdapter(child: SizedBox())
              : const SliverToBoxAdapter(child: SizedBox()),
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 10,
        ),
      ),
      text('Browse Categories'),
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 15,
        ),
      ),
      categories(),
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 10,
        ),
      ),
      text('Fresh Recomendations'),
      gridContent(homeState),
      if (homeState.isLoadingMore) fetchingMoreHomeAds()
    ];
  }

  CupertinoSliverRefreshControl refreshIos() {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        ref.read(homeAdsprovider.notifier).refreshItems();
      },
    );
  }

  CustomScrollView scrollView(HomeAdState homeState) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: homeAdScrollController,
      slivers: homeState.items.isEmpty ? emptySlivers() : slivers(homeState),
    );
  }

  Widget retry() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Something went wrong',
            style: GoogleFonts.lato(),
          ),
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
                    await ref.read(homeAdsprovider.notifier).refreshItems();
                  },
                  child: Text(
                    'Retry',
                    style: GoogleFonts.lato(),
                  ),
                )
              : CupertinoButton(
                  onPressed: () async {
                    final x = ref.refresh(connectivityProvider);
                    final y = ref.refresh(internetCheckerProvider);
                    debugPrint(x.toString());
                    debugPrint(y.toString());
                    await ref.read(homeAdsprovider.notifier).refreshItems();
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

  @override
  Widget build(BuildContext context) {
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
                final homeItemState = ref.watch(homeAdsprovider);
                return homeItemState.when(
                  data: (homeState) {
                    if (Platform.isAndroid) {
                      return RefreshIndicator(
                        color: Colors.blue,
                        child: scrollView(homeState),
                        onRefresh: () async {
                          ref.read(homeAdsprovider.notifier).refreshItems();
                        },
                      );
                    } else if (Platform.isIOS) {
                      return scrollView(homeState);
                    }
                    return const SizedBox();
                  },
                  error: (error, _) => retry(),
                  loading: spinner,
                );
              }
            },
            error: (error, _) => retry(),
            loading: progressIndicator,
          );
        }
      },
      error: (error, _) => retry(),
      loading: progressIndicator,
    );
  }
}
