import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Android_Files/auth_screens/login_android.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/Android_Files/screens/myads/android_soldAds.dart';
import 'package:resell/UIPart/Android_Files/screens/profile/about_android.dart';
import 'package:resell/UIPart/Android_Files/screens/profile/policies_android.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AndroidProfile extends StatefulWidget {
  const AndroidProfile({super.key});

  @override
  State<AndroidProfile> createState() => _AndroidProfileState();
}

class _AndroidProfileState extends State<AndroidProfile> {
  late AuthHandler handler;
  List<ProfileCategory> profileList = const [
    ProfileCategory(
        icon: Icons.check_circle_outline_outlined, title: 'My Sold Ads'),
    ProfileCategory(icon: Icons.person, title: 'About'),
    ProfileCategory(icon: Icons.share, title: 'Share'),
    ProfileCategory(icon: Icons.book, title: 'Policies'),
    ProfileCategory(icon: Icons.logout, title: 'Logout')
  ];
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  void logout(BuildContext logoutContext) async {
    try {
      await handler.changeTheLastSeenTime();
      await Future.delayed(const Duration(milliseconds: 900));
      await handler.firebaseAuth.signOut();
      final sharedPref = await SharedPreferences.getInstance();
      await sharedPref.clear();
      handler.newUser.user = null;
      if (context.mounted) {
        Navigator.of(logoutContext).pop();
        
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(logoutContext).pop();
        
      }
    }
  }

  void spinner() async {
    final internetCheck = await InternetConnection().hasInternetAccess;
    if (internetCheck) {
      late BuildContext logoutContext;
      showDialog(
        context: context,
        builder: (ctx) {
          logoutContext = ctx;
          logout(logoutContext);
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: const Text(
          'My Account',
        ),
      ),
      body: SafeArea(
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
                      Icons.person,
                      color: Colors.black,
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
                      style: const TextStyle(
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
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (ctx) => const AndroidSoldads(),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return const AboutAndroid();
                        }));
                      } else if (index == 2) {
                        Share.share("hello");
                      } else if (index == 3) {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (ctx) => const PoliciesAndroid(),
                          ),
                        );
                      } else {
                        
                      }
                    },
                    child: Column(
                      children: [
                        ListTile(
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
                            style: const TextStyle(
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
                    ),
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
