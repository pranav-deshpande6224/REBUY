
import 'package:flutter/cupertino.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/IOS_Files/screens/home/home.dart';
import 'package:resell/UIPart/IOS_Files/screens/profile/profile.dart';

import 'chats/chats.dart';
import 'myads/active_ads.dart';
import 'sell/sell.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    WidgetsBinding.instance.addObserver(this);
    makingOnline();
    super.initState();
  }

  void makingOnline() async {
    await handler.changingUserToOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        await handler.changingUserToOnline();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        await handler.changeTheLastSeenTime();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            activeColor: CupertinoColors.activeBlue,
            inactiveColor: CupertinoColors.systemGrey,
            items: const [
              BottomNavigationBarItem(
                activeIcon: Icon(
                  CupertinoIcons.house_fill,
                  color: CupertinoColors.activeBlue,
                ),
                icon: Icon(
                  CupertinoIcons.home,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  CupertinoIcons.chat_bubble_fill,
                  color: CupertinoColors.activeBlue,
                ),
                icon: Icon(
                  CupertinoIcons.chat_bubble,
                ),
                label: 'chats',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  CupertinoIcons.add_circled_solid,
                  color: CupertinoColors.activeBlue,
                ),
                icon: Icon(
                  CupertinoIcons.add_circled,
                ),
                label: 'Sell',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  CupertinoIcons.heart_fill,
                  color: CupertinoColors.activeBlue,
                ),
                icon: Icon(CupertinoIcons.heart),
                label: 'My ADS',
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  CupertinoIcons.person_fill,
                  color: CupertinoColors.activeBlue,
                ),
                icon: Icon(CupertinoIcons.person),
                label: 'account',
              ),
            ]),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) => const Home(),
              );
            case 1:
              return CupertinoTabView(
                builder: (context) => const Chats(),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => const Sell(),
              );
            case 3:
              return CupertinoTabView(
                builder: (context) => const MyAds(),
              );
            case 4:
              return CupertinoTabView(
                builder: (context) => const Profile(),
              );
            default:
              return CupertinoTabView(
                builder: (context) => const Home(),
              );
          }
        },
      ),
    );
  }
}
