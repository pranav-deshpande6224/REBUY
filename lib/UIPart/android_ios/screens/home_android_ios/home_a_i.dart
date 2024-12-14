import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/display_home_ads_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/favourite_screen.dart';

class HomeAI extends StatelessWidget {
  const HomeAI({super.key});

  Widget displayHome() {
    return const SafeArea(
      child: Column(
        children: [
          Expanded(
            child: DisplayHomeAdsAI(),
          )
        ],
      ),
    );
  }

  Widget android(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              size: 35,
              color: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const FavouriteScreen(),
                ),
              );
            },
          )
        ],
        backgroundColor: Colors.grey[200],
        title: Image.asset(
          'assets/images/branding6.png',
          height: 50,
          width: 150,
        ),
      ),
      body: displayHome(),
    );
  }

  Widget ios(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Image.asset(
          'assets/images/branding6.png',
          height: 50,
          width: 150,
        ),
      ),
      child: displayHome(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android(context);
    }
    if (Platform.isIOS) {
      return ios(context);
    }
    return const Placeholder();
  }
}
