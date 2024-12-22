import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/Providers/check_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  AuthHandler authHandler = AuthHandler.authHandlerInstance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<int> getAndroidVersion() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final String versionString = androidInfo.version.release;
    final int androidVersion = int.tryParse(versionString.split(".")[0]) ?? 0;
    return androidVersion;
  }

  Future<void> initNotifications(BuildContext context) async {
    final androidVersion = await getAndroidVersion();
    if (androidVersion >= 13) {
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
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        showPermisssionAlert(context);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isPermissionRequested = prefs.getBool('notification') ?? false;
      if (!isPermissionRequested) {
        final status = await Permission.notification.request();
        if (status == PermissionStatus.granted) {
          await prefs.setBool('notification', true);
          final fcmToken = await messaging.getToken();
          if (fcmToken != null) {
            await authHandler.storeFCMToken(fcmToken);
          }
        } else if (status == PermissionStatus.denied) {
          showPermisssionAlert(context);
        } else if (status == PermissionStatus.permanentlyDenied) {
          showPermisssionAlert(context);
        }
      }
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        await authHandler.fireStore
            .collection('users')
            .doc(authHandler.newUser.user!.uid)
            .update({'fcmToken': newToken});
      },
    );
  }

  void showPermisssionAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Allow Notifications",
          style: GoogleFonts.lato(),
        ),
        content: Text("Please enable them to stay updated.",
            style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: GoogleFonts.lato()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    final opened = await openAppSettings();
    if (!opened) {
      print("Failed to open app settings");
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
          if (ref.read(globalRecIdAdIdProvider) == null) {
            if (postedBy == authHandler.newUser.user!.uid) {
              ref.read(topNavIndexProvider.notifier).state = 1;
            } else {
              ref.read(topNavIndexProvider.notifier).state = 0;
            }
          } else {
            Navigator.of(context).pop();
            if (postedBy == authHandler.newUser.user!.uid) {
              ref.read(topNavIndexProvider.notifier).state = 1;
            } else {
              ref.read(topNavIndexProvider.notifier).state = 0;
            }
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
            importance: Importance.max,
            priority: Priority.high,
            icon: 'n_logo');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);
  }
}
