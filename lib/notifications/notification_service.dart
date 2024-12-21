import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';

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

  Future<void> initLocalNotificationsAndroid() async {
    // Android initialization
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('logo9');
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        final message = notificationResponse.payload;
        if (message != null) {
          debugPrint(message);
        }
      },
    );
  }

  Future<void> showNotification({int id = 0, required String title, required String body, String? payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'logo9'
           );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        id, title, body, notificationDetails,
        payload: payload);
  }
}