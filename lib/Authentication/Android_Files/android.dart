
import 'package:flutter/material.dart';
import 'package:resell/Authentication/Android_Files/auth_screens/login_android.dart';
import 'package:resell/UIPart/Android_Files/screens/bottom_nav_android.dart';

class Android extends StatelessWidget {
  final bool isUserLoggedIn;
  const Android({
    required this.isUserLoggedIn,
    super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(
       
      ),
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn? const BottomNavAndroid() :  const LoginAndroid(),
    );
  }
}
