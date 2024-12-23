import 'dart:io';
import 'dart:convert';
import 'package:eraser/eraser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/chats_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/home_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/myads_android_ios/myads_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/profile_android_ios/profile_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/sell_android_ios/sell_a_i.dart';
import 'package:resell/notifications/notification_service.dart';

class BottomNavAI extends ConsumerStatefulWidget {
  const BottomNavAI({super.key});

  @override
  ConsumerState<BottomNavAI> createState() => _BottomNavAIState();
}

class _BottomNavAIState extends ConsumerState<BottomNavAI>
    with WidgetsBindingObserver {
  late AuthHandler handler;
  final screens = const [
    HomeAI(),
    ChatsAI(),
    SellAI(),
    MyadsAI(),
    ProfileAI(),
  ];
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    if (Platform.isAndroid) {
      getNotifications();
    }
    WidgetsBinding.instance.addObserver(this);
    makingOnline();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['navigate_to'] == 'chats') {
        ref.read(bottomNavIndexProvider.notifier).state = 1;
        final String postedBy = message.data['postedBy'];
        final String adId = message.data['adId'];
        Navigator.of(context).popUntil((route) => route.isFirst);
        int index = ref.read(bottomNavIndexProvider);
        if (index != 1) {
          ref.read(bottomNavIndexProvider.notifier).state = 1;
          ref
              .read(chatNotificationProvider.notifier)
              .setNotificationData(postedBy, adId);
          if (postedBy == handler.newUser.user!.uid) {
            ref.read(topNavIndexProvider.notifier).state = 1;
          } else {
            ref.read(topNavIndexProvider.notifier).state = 0;
          }
        } else {
          ref
              .read(chatNotificationProvider.notifier)
              .setNotificationData(postedBy, adId);
          if (postedBy == handler.newUser.user!.uid) {
            ref.read(topNavIndexProvider.notifier).state = 1;
          } else {
            ref.read(topNavIndexProvider.notifier).state = 0;
          }
        }
      }
    });
    onforegroundNotification();
    recievingNotifications();
    super.initState();
  }

  void recievingNotifications() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      if (message.data['navigate_to'] == 'chats') {
        ref.read(bottomNavIndexProvider.notifier).state = 1;
        final String postedBy = message.data['postedBy'];
        final String adId = message.data['adId'];
        // Navigator.of(context).popUntil((route) => route.isFirst);
        int index = ref.read(bottomNavIndexProvider);
        if (index != 1) {
          ref.read(bottomNavIndexProvider.notifier).state = 1;
          ref
              .read(chatNotificationProvider.notifier)
              .setNotificationData(postedBy, adId);
          if (postedBy == handler.newUser.user!.uid) {
            ref.read(topNavIndexProvider.notifier).state = 1;
          } else {
            ref.read(topNavIndexProvider.notifier).state = 0;
          }
          message = null;
        } else {
          ref
              .read(chatNotificationProvider.notifier)
              .setNotificationData(postedBy, adId);
          if (postedBy == handler.newUser.user!.uid) {
            ref.read(topNavIndexProvider.notifier).state = 1;
          } else {
            ref.read(topNavIndexProvider.notifier).state = 0;
          }
          message = null;
        }
      }
    }
  }

  void onforegroundNotification() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (message.notification != null) {
          Map<String, dynamic> data = message.data;
          final String msgSentById = data['messageSentById'];
          final String recId_adId = data['recId_adId'];
          final String postedBy = data['postedBy'];
          final String adId = data['adId'];
          final getRecId_adId = ref.read(globalRecIdAdIdProvider);
          if (msgSentById != handler.newUser.user!.uid &&
              getRecId_adId != recId_adId) {
            NotificationService().showNotification(
              title: message.notification!.title ?? 'New Message',
              body: message.notification!.body ?? '',
              payload: jsonEncode({
                'postedBy': postedBy,
                'adId': adId,
              }),
            );
          }
        }
      },
    );
  }

  void getNotifications() {
    NotificationService().initNotifications(context);
    NotificationService().initLocalNotificationsAndroid(context, ref);
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
        await Eraser.clearAllAppNotifications();
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

  Widget android() {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (value) {
          ref.read(bottomNavIndexProvider.notifier).state = value;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'MyAds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'account',
          ),
        ],
      ),
    );
  }

  Widget ios() {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(items: const [
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
              CupertinoIcons.star_fill,
              color: CupertinoColors.activeBlue,
            ),
            icon: Icon(CupertinoIcons.star),
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
                builder: (context) => const HomeAI(),
              );
            case 1:
              return CupertinoTabView(
                builder: (context) => ChatsAI(),
              );
            case 2:
              return CupertinoTabView(
                builder: (context) => const SellAI(),
              );
            case 3:
              return CupertinoTabView(
                builder: (context) => const MyadsAI(),
              );
            case 4:
              return CupertinoTabView(
                builder: (context) => const ProfileAI(),
              );
            default:
              return CupertinoTabView(
                builder: (context) => const HomeAI(),
              );
          }
        },
      ),
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
