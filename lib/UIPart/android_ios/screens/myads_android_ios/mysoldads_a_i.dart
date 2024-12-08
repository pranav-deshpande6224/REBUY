import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/widgets/ad_card.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/show_sold_ads.dart';

class MysoldadsAI extends ConsumerStatefulWidget {
  const MysoldadsAI({super.key});

  @override
  ConsumerState<MysoldadsAI> createState() => _MysoldadsAIState();
}

class _MysoldadsAIState extends ConsumerState<MysoldadsAI> {
  late AuthHandler handler;
  final ScrollController soldAdScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    if (handler.newUser.user == null) {
      moveToLogin();
      return;
    }
    handler = AuthHandler.authHandlerInstance;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(showSoldAdsProvider.notifier).fetchInitialItems();
      },
    );
    soldAdScrollController.addListener(
      () {
        double maxScroll = soldAdScrollController.position.maxScrollExtent;
        double currentScroll = soldAdScrollController.position.pixels;
        double delta = MediaQuery.of(context).size.width * 0.20;
        if (maxScroll - currentScroll <= delta) {
          ref.read(showSoldAdsProvider.notifier).fetchMoreItems();
        }
      },
    );
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
  void dispose() {
    soldAdScrollController.dispose();
    super.dispose();
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
                    await ref.read(showSoldAdsProvider.notifier).refreshItems();
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
                    await ref.read(showSoldAdsProvider.notifier).refreshItems();
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
              await ref.read(showSoldAdsProvider.notifier).refreshItems();
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

  CupertinoSliverRefreshControl refreshIos() {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        ref.read(showSoldAdsProvider.notifier).refreshItems();
      },
    );
  }

  SliverFillRemaining noSoldAds() {
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
    );
  }

  SliverList havingSoldAds(SoldAdState soldAdState) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final item = soldAdState.items[index];
          return AdCard(
            cardIndex: index,
            ad: item,
            adSold: null,
            isSold: true,
          );
        },
        childCount: soldAdState.items.length,
      ),
    );
  }

  SliverToBoxAdapter loadingMoreSoldAds() {
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

  List<Widget> slivers(SoldAdState soldAdState) {
    if (Platform.isAndroid) {
      return [
        soldAdState.items.isEmpty ? noSoldAds() : havingSoldAds(soldAdState),
        if (soldAdState.isLoadingMore) loadingMoreSoldAds()
      ];
    } else if (Platform.isIOS) {
      return [
        refreshIos(),
        soldAdState.items.isEmpty ? noSoldAds() : havingSoldAds(soldAdState),
        if (soldAdState.isLoadingMore) loadingMoreSoldAds()
      ];
    }
    return [];
  }

  CustomScrollView scrollView(SoldAdState soldAdState) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: soldAdScrollController,
      slivers: slivers(soldAdState),
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
          'My Sold Ads',
          style: GoogleFonts.roboto(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
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
                    final soldItemState = ref.watch(showSoldAdsProvider);
                    return soldItemState.when(
                      data: (soldAdState) {
                        return RefreshIndicator(
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: scrollView(soldAdState),
                          ),
                          onRefresh: () async {
                            await ref
                                .read(showSoldAdsProvider.notifier)
                                .refreshItems();
                          },
                        );
                      },
                      error: (error, stack) => retry(),
                      loading: spinner,
                    );
                  }
                },
                error: (error, stack) => retry(),
                loading: progressIndicator,
              );
            }
          },
          error: (error, stack) => retry(),
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
          'MY SOLD ADS',
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
                    final soldItemState = ref.watch(showSoldAdsProvider);
                    return soldItemState.when(
                      data: (soldAdState) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: scrollView(soldAdState),
                        );
                      },
                      error: (error, stack) => retry(),
                      loading: spinner,
                    );
                  }
                },
                error: (error, stack) => retry(),
                loading: progressIndicator,
              );
            }
          },
          error: (error, stack) => retry(),
          loading: progressIndicator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(showSoldAdsProvider.notifier).resetState();
      },
      child: Platform.isAndroid
          ? android()
          : Platform.isIOS
              ? ios()
              : const SizedBox(),
    );
  }
}
