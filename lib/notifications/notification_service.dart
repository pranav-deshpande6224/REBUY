import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  AuthHandler authHandler = AuthHandler.authHandlerInstance;
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
}
