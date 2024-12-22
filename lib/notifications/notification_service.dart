import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  AuthHandler authHandler = AuthHandler.authHandlerInstance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      provisional: true,
      criticalAlert: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        await authHandler.storeFCMToken(fcmToken);
        FirebaseMessaging.instance.onTokenRefresh.listen(
          (newToken) async {
            await authHandler.fireStore
                .collection('users')
                .doc(authHandler.newUser.user!.uid)
                .update({'fcmToken': newToken});
          },
        );
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint("denied");
    }
  }

  Future<void> initLocalNotificationsAndroid(
      BuildContext context, WidgetRef ref) async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('n_logo');
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        final message = notificationResponse.payload;
        final data = jsonDecode(message!) as Map<String, dynamic>;
        final String postedBy = data['postedBy'];
        final String adId = data['adId'];
        Navigator.of(context).popUntil((route) => route.isFirst);
        int index = ref.read(bottomNavIndexProvider);
        if (index != 1) {
          ref.read(bottomNavIndexProvider.notifier).state = 1;
          ref
              .read(chatNotificationProvider.notifier)
              .setNotificationData(postedBy, adId);
          print('posted by in init noti $postedBy');
          print('ad id in init noti $adId');
          if (postedBy == authHandler.newUser.user!.uid) {
            print(authHandler.newUser.user!.uid);
            ref.read(topNavIndexProvider.notifier).state = 1;
          } else {
            ref.read(topNavIndexProvider.notifier).state = 0;
          }
        } else {
          ref
              .read(chatNotificationProvider.notifier)
              .setNotificationData(postedBy, adId);
          if (postedBy == authHandler.newUser.user!.uid) {
            ref.read(topNavIndexProvider.notifier).state = 1;
          } else {
            ref.read(topNavIndexProvider.notifier).state = 0;
          }
        }
      },
    );
  }

  Future<void> showNotification(
      {int id = 0,
      required String title,
      required String body,
      String? payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            importance: Importance.max, priority: Priority.high, icon: 'n_logo');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);
  }
}
