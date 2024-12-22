import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/category_ads_pagination.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/favourite_ads_pagination.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/home_ads.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/show_ads.dart';
import 'package:resell/UIPart/android_ios/Providers/pagination_active_ads/show_sold_ads.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/UIPart/android_ios/screens/myads_android_ios/mysoldads_a_i.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAI extends ConsumerStatefulWidget {
  const ProfileAI({super.key});

  @override
  ConsumerState<ProfileAI> createState() => _ProfileAIState();
}

class _ProfileAIState extends ConsumerState<ProfileAI> {
  List<ProfileCategory> profileList = [
    ProfileCategory(
        icon: Platform.isAndroid
            ? Icons.check_circle_outline_outlined
            : Platform.isIOS
                ? CupertinoIcons.check_mark_circled
                : Icons.photo,
        title: 'My Sold Ads'),
    ProfileCategory(
        icon: Platform.isAndroid
            ? Icons.share
            : Platform.isIOS
                ? CupertinoIcons.share
                : Icons.photo,
        title: 'Share'),
    ProfileCategory(
        icon: Platform.isAndroid
            ? Icons.logout
            : Platform.isIOS
                ? CupertinoIcons.square_arrow_right
                : Icons.photo,
        title: 'Logout')
  ];

  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    if (handler.newUser.user == null) {
      moveToLogin();
    }
    super.initState();
  }

  void logout(BuildContext signOutContext) async {
    try {
      await handler.changeTheLastSeenTime();
      await handler.fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .update({'fcmToken': ''});
      await Future.delayed(const Duration(milliseconds: 900));
      await handler.firebaseAuth.signOut();
      final sharedPref = await SharedPreferences.getInstance();
      await sharedPref.clear();
      handler.newUser.user = null;
      ref.read(showActiveAdsProvider.notifier).resetState();
      ref.read(showSoldAdsProvider.notifier).resetState();
      ref.read(homeAdsprovider.notifier).resetState();
      ref.read(showCatAdsProvider.notifier).resetState();
      ref.read(favouriteAdsProvider.notifier).resetState();
      ref.read(globalRecIdAdIdProvider.notifier).clearAdId();
      ref.read(bottomNavIndexProvider.notifier).state = 0;
      ref.read(topNavIndexProvider.notifier).state = 0;
      ref.read(chatNotificationProvider.notifier).clearNotificationData();
      if (!signOutContext.mounted) return;
      Navigator.pop(signOutContext);
      moveToLogin();
    } catch (e) {
      Navigator.pop(signOutContext);
      errorWhileLogout(e.toString());
    }
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

  void errorWhileLogout(String error) {
    if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong',
            style: GoogleFonts.lato(),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
              'Alert',
              style: GoogleFonts.lato(),
            ),
            content: Text(
              error,
              style: GoogleFonts.lato(),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Okay',
                  style: GoogleFonts.lato(),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void moveToSoldAds() {
    if (Platform.isAndroid) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const MysoldadsAI()));
    } else if (Platform.isIOS) {
      Navigator.of(context, rootNavigator: true)
          .push(CupertinoPageRoute(builder: (ctx) => const MysoldadsAI()));
    }
  }

  void spinner() async {
    late BuildContext signOutContext;
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (Platform.isAndroid) {
      if (hasInternet) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) {
              signOutContext = ctx;
              logout(signOutContext);
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No Internet',
                style: GoogleFonts.lato(),
              ),
            ),
          );
        }
      }
    } else if (Platform.isIOS) {
      if (hasInternet) {
        showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              signOutContext = ctx;
              logout(signOutContext);
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
                      style: GoogleFonts.lato(),
                    )
                  ],
                ),
              );
            });
      } else {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  'No Internet',
                  style: GoogleFonts.lato(),
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Okay',
                      style: GoogleFonts.lato(),
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

  Widget content() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Platform.isAndroid
                        ? Icons.person
                        : Platform.isIOS
                            ? CupertinoIcons.person
                            : null,
                    color: Platform.isAndroid
                        ? Colors.black
                        : Platform.isIOS
                            ? CupertinoColors.black
                            : null,
                    size: 35,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    handler.newUser.user?.displayName ?? '',
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (ctx, index) {
                final obj = profileList[index];
                return Platform.isAndroid
                    ? ListTile(
                        onTap: () {
                          if (index == 0) {
                            moveToSoldAds();
                          } else if (index == 1) {
                            Share.share("hello");
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text(
                                    'Alert',
                                  ),
                                  content: const Text(
                                    'Are you sure want to Logout',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text(
                                        'No',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        spinner();
                                      },
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                        leading: Icon(
                          obj.icon,
                          size: 30,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                        ),
                        title: Text(
                          obj.title,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Platform.isIOS
                        ? CupertinoListTile(
                            onTap: () {
                              if (index == 0) {
                                moveToSoldAds();
                              } else if (index == 1) {
                                Share.share("hello");
                              } else {
                                showCupertinoDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) {
                                    return CupertinoAlertDialog(
                                      title: Text('Alert',
                                          style: GoogleFonts.lato()),
                                      content: Text(
                                        'Are you sure want to Logout',
                                        style: GoogleFonts.lato(),
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text(
                                            'No',
                                            style: GoogleFonts.lato(),
                                          ),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            spinner();
                                          },
                                          child: Text(
                                            'Yes',
                                            style: GoogleFonts.lato(
                                              color: CupertinoColors.systemRed,
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            title: Text(
                              obj.title,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(
                              CupertinoIcons.right_chevron,
                              color: CupertinoColors.activeBlue,
                            ),
                            leading: Icon(
                              obj.icon,
                              size: 30,
                            ),
                          )
                        : const SizedBox();
              },
              separatorBuilder: (context, index) {
                return Platform.isAndroid
                    ? const Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      )
                    : Platform.isIOS
                        ? Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                          )
                        : const SizedBox();
              },
              itemCount: profileList.length,
            )
          ],
        ),
      ),
    );
  }

  Widget ios() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'My Account',
          style: GoogleFonts.lato(),
        ),
      ),
      child: content(),
    );
  }

  Widget android() {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Text(
          'My Account',
          style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: content(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android();
    }
    if (Platform.isIOS) {
      return ios();
    }
    return const SizedBox();
  }
}
