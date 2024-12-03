import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/UIPart/IOS_Files/screens/myads/my_sold_ads.dart';
import 'package:resell/UIPart/IOS_Files/screens/profile/about.dart';
import 'package:resell/UIPart/IOS_Files/screens/profile/policies.dart';
import 'package:resell/UIPart/Providers/pagination_active_ads/category_ads_pagination.dart';
import 'package:resell/UIPart/Providers/pagination_active_ads/home_ads.dart';
import 'package:resell/UIPart/Providers/pagination_active_ads/show_ads.dart';
import 'package:resell/UIPart/Providers/pagination_active_ads/show_sold_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  List<ProfileCategory> profileList = const [
    ProfileCategory(
        icon: CupertinoIcons.check_mark_circled, title: 'My Sold Ads'),
    ProfileCategory(icon: CupertinoIcons.person, title: 'About'),
    ProfileCategory(icon: CupertinoIcons.share, title: 'Share'),
    ProfileCategory(icon: CupertinoIcons.book, title: 'Policies'),
    ProfileCategory(icon: CupertinoIcons.square_arrow_right, title: 'Logout')
  ];
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  void moveToLogin() {
    
  }

  Future<void> executeSignOut(BuildContext signOutContext) async {
    final internetConnection = await InternetConnection().hasInternetAccess;
    if (internetConnection) {
      try {
        await handler.changeTheLastSeenTime();
        await Future.delayed(const Duration(milliseconds: 900));
        await handler.firebaseAuth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        handler.newUser.user = null;
        ref.read(showActiveAdsProvider.notifier).resetState();
        ref.read(showSoldAdsProvider.notifier).resetState();
        ref.read(homeAdsprovider.notifier).resetState();
        ref.read(showCatAdsProvider.notifier).resetState();

        if (!signOutContext.mounted) return;
        Navigator.pop(signOutContext);
        moveToLogin();
      } catch (e) {
        Navigator.pop(signOutContext);
        if (!context.mounted) return;
        
      }
    } else {
      if (signOutContext.mounted) {
        Navigator.pop(signOutContext);

        showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(
                'No Internet',
                style: GoogleFonts.roboto(),
              ),
              content: Text(
                'Please check your internet connection and try again',
                style: GoogleFonts.roboto(),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(ctx).pop();
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

  void spinner() {
    late BuildContext signOutContext;
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        signOutContext = ctx;
        executeSignOut(signOutContext);
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
                style: GoogleFonts.roboto(),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'My Account',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
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
                    child: const Icon(
                      CupertinoIcons.person,
                      color: CupertinoColors.black,
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
                      style: GoogleFonts.roboto(
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
              ListView.builder(
                shrinkWrap: true,
                itemCount: profileList.length,
                itemBuilder: (ctx, index) {
                  final obj = profileList[index];
                  return Column(
                    children: [
                      CupertinoListTile(
                        onTap: () {
                          if (index == 0) {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (ctx) => MySoldAds(),
                              ),
                            );
                          } else if (index == 1) {
                            Navigator.of(context, rootNavigator: true)
                                .push(CupertinoPageRoute(builder: (ctx) {
                              return About();
                            }));
                          } else if (index == 2) {
                            Share.share("hello");
                          } else if (index == 3) {
                            Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                builder: (ctx) => const Policies(),
                              ),
                            );
                          } else {
                            
                          }
                        },
                        leading: Icon(
                          obj.icon,
                          size: 30,
                        ),
                        trailing: const Icon(
                          CupertinoIcons.right_chevron,
                          color: CupertinoColors.activeBlue,
                        ),
                        title: Text(
                          obj.title,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
