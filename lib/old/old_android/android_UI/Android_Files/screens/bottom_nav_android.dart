import 'package:flutter/material.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/chats/android_chats.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/home/android_home.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/myads/android_myAds.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/profile/android_profile.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/sell/android_sell.dart';

class BottomNavAndroid extends StatefulWidget {
  const BottomNavAndroid({super.key});

  @override
  State<BottomNavAndroid> createState() => _BottomNavAndroidState();
}

class _BottomNavAndroidState extends State<BottomNavAndroid> {
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  int currentIndex = 0;
  final screens = [
    const AndroidHome(),
    const AndroidChats(),
    const AndroidSell(),
    const AndroidMyads(),
    const AndroidProfile()
  ];

  @override
  Widget build(BuildContext context) {
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
          setState(() {
            currentIndex = value;
          });
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
            icon: Icon(Icons.favorite),
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
}
