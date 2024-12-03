import 'package:flutter/cupertino.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/bottom_nav_a_i.dart';

class Ios extends StatelessWidget {
  final bool isUserLoggedIn;
  const Ios({required this.isUserLoggedIn, super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn ? const BottomNavAI() : const LoginAI(),
    );
  }
}
