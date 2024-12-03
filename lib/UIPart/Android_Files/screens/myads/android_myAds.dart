import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Android_Files/auth_screens/login_android.dart';
import 'package:resell/Authentication/Providers/internet_provider.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';
import 'package:resell/UIPart/IOS_Files/widgets/ad_card.dart';
import 'package:resell/UIPart/Providers/pagination_active_ads/show_ads.dart';

class AndroidMyads extends ConsumerStatefulWidget {
  const AndroidMyads({super.key});

  @override
  ConsumerState<AndroidMyads> createState() => _AndroidMyadsState();
}

class _AndroidMyadsState extends ConsumerState<AndroidMyads> {
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

  void sellTheItem(Item item) async {
    if (handler.newUser.user != null) {
      final firestore = handler.fireStore;
      late BuildContext sellContext;
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (context.mounted) {
        if (!hasInternet) {
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
        } else {
          try {
            showDialog(
                context: context,
                builder: (ctx) {
                  sellContext = ctx;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                });
            await firestore.runTransaction((transaction) async {
              DocumentReference<Map<String, dynamic>> ref = firestore
                  .collection('users')
                  .doc(handler.newUser.user!.uid)
                  .collection('MyActiveAds')
                  .doc(item.id);

              DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
              DocumentReference<Map<String, dynamic>> docRef =
                  snapshot.reference;
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
            ref.read(showActiveAdsProvider.notifier).deleteItem(item);
            if (sellContext.mounted) {
              Navigator.of(sellContext).pop();
            }
          } catch (e) {
            if (sellContext.mounted) {
              Navigator.of(sellContext).pop();
            }
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
          }
        }
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const LoginAndroid()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    activeAdScrollController.dispose();
    super.dispose();
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
          'My Ads',
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
                            .read(showActiveAdsProvider.notifier)
                            .refreshItems();
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
                                  .read(showActiveAdsProvider.notifier)
                                  .refreshItems();
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    final itemState = ref.watch(showActiveAdsProvider);
                    return itemState.when(
                        data: (adState) {
                          return RefreshIndicator(
                            color: Colors.blue,
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: activeAdScrollController,
                              slivers: [
                                adState.items.isEmpty
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
                                                'No Active Ads',
                                                style: GoogleFonts.roboto(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'You don’t have any active ads yet. Sell one now!',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SliverPadding(
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
                                      ),
                                if (adState.isLoadingMore)
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
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onRefresh: () async {
                              await ref
                                  .read(showActiveAdsProvider.notifier)
                                  .refreshItems();
                            },
                          );
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
                        });
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
            ),
          ),
        ),
      ),
    );
  }
}
