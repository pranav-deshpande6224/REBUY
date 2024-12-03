import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/widgets/ad_card.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/show_ads.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class MyadsAI extends ConsumerStatefulWidget {
  const MyadsAI({super.key});

  @override
  ConsumerState<MyadsAI> createState() => _MyadsAIState();
}

class _MyadsAIState extends ConsumerState<MyadsAI> {
  late AuthHandler handler;
  final ScrollController activeAdScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    handler = AuthHandler.authHandlerInstance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(showActiveAdsProvider.notifier).fetchInitialItems();
    });
    activeAdScrollController.addListener(() {
      double maxScroll = activeAdScrollController.position.maxScrollExtent;
      double currentScroll = activeAdScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.width * 0.20;
      if (maxScroll - currentScroll <= delta) {
        ref.read(showActiveAdsProvider.notifier).fetchMoreItems();
      }
    });
  }

  @override
  void dispose() {
    activeAdScrollController.dispose();
    super.dispose();
  }

  Future<void> runTheTransaction(Item item) async {
    final firestore = handler.fireStore;
    await firestore.runTransaction((transaction) async {
      DocumentReference<Map<String, dynamic>> ref = firestore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('MyActiveAds')
          .doc(item.id);
      DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
      DocumentReference<Map<String, dynamic>> docRef = snapshot.reference;
      Query<Map<String, dynamic>> allAdsQuery = firestore
          .collection('AllAds')
          .where('adReference', isEqualTo: docRef);
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await allAdsQuery.get();
      Query<Map<String, dynamic>> categoryAdsQuery = firestore
          .collection('Category')
          .doc(item.categoryName)
          .collection('Subcategories')
          .doc(item.subCategoryName)
          .collection('Ads')
          .where('adReference', isEqualTo: docRef);
      QuerySnapshot<Map<String, dynamic>> categoryQuerySnapshot =
          await categoryAdsQuery.get();
      await querySnapshot.docs.first.reference.delete();
      await categoryQuerySnapshot.docs.first.reference.delete();
      item = item.copyWith(isAvailable: false);
      await docRef.update(item.toJson());
    });
  }

  void sellTheItem(Item item) async {
    if (handler.newUser.user != null) {
      late BuildContext sellContext;
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (context.mounted) {
        if (!hasInternet) {
          if (Platform.isAndroid) {
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('No Internet Connection'),
                  content: const Text(
                      'Please check your internet connection and try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'OK',
                        style: GoogleFonts.roboto(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (Platform.isIOS) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) {
                return CupertinoAlertDialog(
                  title: const Text('No Internet Connection'),
                  content: const Text(
                      'Please check your internet connection and try again.'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          try {
            if (Platform.isAndroid) {
              showDialog(
                context: context,
                builder: (ctx) {
                  sellContext = ctx;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                },
              );
            } else if (Platform.isIOS) {
              showCupertinoDialog(
                context: context,
                builder: (ctx) {
                  sellContext = ctx;
                  return const Center(
                    child: CupertinoActivityIndicator(
                      radius: 15,
                      color: CupertinoColors.black,
                    ),
                  );
                },
              );
            }
            await runTheTransaction(item);
            ref.read(showActiveAdsProvider.notifier).deleteItem(item);
            if (sellContext.mounted) {
              Navigator.of(sellContext).pop();
            }
          } catch (e) {
            if (sellContext.mounted) {
              Navigator.of(sellContext).pop();
            }
            if (Platform.isAndroid) {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text(
                      'Alert',
                      style: GoogleFonts.roboto(),
                    ),
                    content: Text(
                      e.toString(),
                      style: GoogleFonts.roboto(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Okay',
                          style: GoogleFonts.roboto(color: Colors.blue),
                        ),
                      )
                    ],
                  );
                },
              );
            } else if (Platform.isIOS) {
              showCupertinoDialog(
                context: context,
                builder: (ctx) {
                  return CupertinoAlertDialog(
                    title: Text(
                      'Alert',
                      style: GoogleFonts.roboto(),
                    ),
                    content: Text(
                      e.toString(),
                      style: GoogleFonts.roboto(),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Okay',
                          style: GoogleFonts.roboto(),
                        ),
                      )
                    ],
                  );
                },
              );
            }
          }
        }
      }
    } else {
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
              await ref.read(showActiveAdsProvider.notifier).refreshItems();
            },
          )
        ],
      ),
    );
  }

  CupertinoSliverRefreshControl cupertinoRefresh() {
    return CupertinoSliverRefreshControl(
      onRefresh: () async {
        await ref.read(showActiveAdsProvider.notifier).refreshItems();
      },
    );
  }

  SliverFillRemaining noActiveAd() {
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
              'No Active Ads',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don’t have any active ads yet. Add one now!',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding havingActiveAds(ActiveAdsState adState) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final item = adState.items[index];
            return AdCard(
              cardIndex: index,
              ad: item,
              adSold: sellTheItem,
              isSold: false,
            );
          },
          childCount: adState.items.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter fetchingMoreActiveAds() {
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

  List<Widget> sliverWidget(ActiveAdsState adState) {
    if (Platform.isAndroid) {
      return [
        adState.items.isEmpty ? noActiveAd() : havingActiveAds(adState),
        if (adState.isLoadingMore) fetchingMoreActiveAds(),
      ];
    } else if (Platform.isIOS) {
      return [
        cupertinoRefresh(),
        adState.items.isEmpty ? noActiveAd() : havingActiveAds(adState),
        if (adState.isLoadingMore) fetchingMoreActiveAds(),
      ];
    }
    return [];
  }

  CustomScrollView scrollView(ActiveAdsState adState) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: activeAdScrollController,
      slivers: sliverWidget(adState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);
    final internetState = ref.watch(internetCheckerProvider);
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 3,
          backgroundColor: Colors.grey[200],
          title: Text(
            'My Active Ads',
            style:
                GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.bold),
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
                        final itemState = ref.watch(showActiveAdsProvider);
                        return itemState.when(
                          data: (adState) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                await ref
                                    .read(showActiveAdsProvider.notifier)
                                    .refreshItems();
                              },
                              color: Colors.blue,
                              child: scrollView(adState),
                            );
                          },
                          error: (error, stack) => Center(
                            child: Text('Error: $error'),
                          ),
                          loading: spinner,
                        );
                      }
                    },
                    error: (error, _) => Center(child: Text('Error: $error')),
                    loading: progressIndicator);
              }
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: progressIndicator,
          ),
        ),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'My Active Ads',
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
                        final itemState = ref.watch(showActiveAdsProvider);
                        return itemState.when(
                          data: (adState) {
                            return scrollView(adState);
                          },
                          error: (error, stack) => Center(
                            child: Text('Error: $error'),
                          ),
                          loading: spinner,
                        );
                      }
                    },
                    error: (error, _) => Center(child: Text('Error: $error')),
                    loading: progressIndicator);
              }
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: progressIndicator,
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
