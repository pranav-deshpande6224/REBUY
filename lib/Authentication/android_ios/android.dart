import 'package:flutter/material.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/bottom_nav_a_i.dart';

class Android extends StatelessWidget {
  final bool isUserLoggedIn;
  const Android({required this.isUserLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn ? const BottomNavAI() : const LoginAI(),
    );
  }
}
