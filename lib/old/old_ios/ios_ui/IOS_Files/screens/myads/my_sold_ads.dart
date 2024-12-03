import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/widgets/ad_card.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/show_sold_ads.dart';

class MySoldAds extends ConsumerStatefulWidget {
  const MySoldAds({super.key});
  @override
  ConsumerState<MySoldAds> createState() => _MySoldAdsState();
}

class _MySoldAdsState extends ConsumerState<MySoldAds> {
  late AuthHandler handler;
  final ScrollController soldAdScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    handler = AuthHandler.authHandlerInstance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showSoldAdsProvider.notifier).fetchInitialItems();
    });
    soldAdScrollController.addListener(() {
      double maxScroll = soldAdScrollController.position.maxScrollExtent;
      double currentScroll = soldAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showSoldAdsProvider.notifier).fetchMoreItems();
      }
    });
  }

  @override
  void dispose() {
    soldAdScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(showSoldAdsProvider.notifier).resetState();
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'MY SOLD ADS',
            style: GoogleFonts.roboto(),
          ),
        ),
        child: SafeArea(
            child: connectivityState.when(
          data: (connectivityResult) {
            if (connectivityResult == ConnectivityResult.none) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
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
                              .read(showSoldAdsProvider.notifier)
                              .refreshItems();
                        })
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
                                    .read(showSoldAdsProvider.notifier)
                                    .refreshItems();
                              })
                        ],
                      ),
                    );
                  } else {
                    final soldItemState = ref.watch(showSoldAdsProvider);
                    return soldItemState.when(
                      data: (soldAdState) {
                        if (soldAdState.items.isEmpty) {
                          return CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: soldAdScrollController,
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: () async {
                                  ref
                                      .read(showSoldAdsProvider.notifier)
                                      .refreshItems();
                                },
                              ),
                              SliverFillRemaining(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/emoji.png',
                                        height: 100,
                                        width: 100,
                                      ),
                                      Text(
                                        'No Sold Ads',
                                        style: GoogleFonts.roboto(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: soldAdScrollController,
                          slivers: [
                            CupertinoSliverRefreshControl(
                              onRefresh: () async {
                                ref
                                    .read(showSoldAdsProvider.notifier)
                                    .refreshItems();
                              },
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, index) {
                                  final item = soldAdState.items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    child: AdCard(
                                      cardIndex: index,
                                      ad: item,
                                      adSold: null,
                                      isSold: true,
                                    ),
                                  );
                                },
                                childCount: soldAdState.items.length,
                              ),
                            ),
                            if (soldAdState.isLoadingMore)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
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
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                      loading: () {
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
                      },
                    );
                  }
                },
                error: (error, _) => Center(child: Text('Error: $error')),
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
              );
            }
          },
          error: (error, _) => Center(child: Text('Error: $error')),
          loading: () => const Center(child: CupertinoActivityIndicator()),
        )),
      ),
    );
  }
}
