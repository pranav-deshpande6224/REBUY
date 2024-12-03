import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/home/product_detail_screen_android.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/sell/android_detail_screen.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/home_ads.dart';
import 'package:resell/constants/constants.dart';

class DisplayHomeAndroid extends ConsumerStatefulWidget {
  const DisplayHomeAndroid({super.key});

  @override
  ConsumerState<DisplayHomeAndroid> createState() => _DisplayHomeAndroidState();
}

class _DisplayHomeAndroidState extends ConsumerState<DisplayHomeAndroid> {
  late AuthHandler handler;
  final ScrollController homeAdScrollController = ScrollController();
  final List<SellCategory> categoryList = const [
    SellCategory(
        icon: Icons.phone,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: Icons.laptop,
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
      icon: Icons.domain,
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
      icon: Icons.book,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
        icon: Icons.tv,
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
      icon: Icons.person_2_rounded,
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
                    final x = ref.refresh(connectivityProvider);
                    final y = ref.refresh(internetCheckerProvider);
                    debugPrint(x.toString());
                    debugPrint(y.toString());
                    await ref.read(homeAdsprovider.notifier).refreshItems();
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
                            style: GoogleFonts.roboto(color: Colors.blue),
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
                        return RefreshIndicator(
                          child: ListView(
                            controller: homeAdScrollController,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Browse Categories',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              AspectRatio(
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
                                            Navigator.of(
                                              context,
                                            ).push(
                                              MaterialPageRoute(
                                                builder: (ctx) =>
                                                    AndroidDetailScreen(
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
                                                        categoryList[index]
                                                            .icon,
                                                        size: 50,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        categoryList[index]
                                                            .categoryTitle,
                                                        style:
                                                            GoogleFonts.roboto(
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
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Fresh Recomendations',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onRefresh: () async {
                            ref.read(homeAdsprovider.notifier).refreshItems();
                          },
                        );
                      } else {
                        return RefreshIndicator(
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: ListView(
                              controller: homeAdScrollController,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Browse Categories',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                AspectRatio(
                                  aspectRatio: 3.5,
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
                                              MaterialPageRoute(
                                                builder: (ctx) =>
                                                    AndroidDetailScreen(
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
                                                        categoryList[index]
                                                            .icon,
                                                        size: 50,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        categoryList[index]
                                                            .categoryTitle,
                                                        style:
                                                            GoogleFonts.roboto(
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
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child: Text(
                                    'Fresh Recomendations',
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: homeState.items.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.74,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemBuilder: (ctx, index) {
                                    final ad = homeState.items[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (ctx) {
                                              return ProductDetailScreenAndroid(
                                                reference: ad.documentReference,
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
                                              color: Colors.blueGrey,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
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
                                                          width:
                                                              double.infinity,
                                                          imageUrl:
                                                              ad.images[0],
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                              url, error) {
                                                            return const Icon(
                                                              Icons.photo,
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
                                                                  fit: BoxFit
                                                                      .cover,
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
                                                      padding:
                                                          const EdgeInsets.all(
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
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              color: Colors
                                                                      .green[
                                                                  700], // Cool color for price
                                                            ),
                                                          ),
                                                          Text(
                                                            ad.adTitle,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .black87, // Darker color for title
                                                            ),
                                                          ),
                                                          Text(
                                                            ad.postedBy,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
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
                                if (homeState.isLoadingMore)
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
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
                                            'Fetching Content...',
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          onRefresh: () async {
                            ref.read(homeAdsprovider.notifier).refreshItems();
                          },
                        );
                      }
                    },
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
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
              loading: () => const Center(
                      child: CircularProgressIndicator(
                    color: Colors.blue,
                  )));
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
}
