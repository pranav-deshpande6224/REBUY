import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/display_home_ads_a_i.dart';

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

  Widget android() {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: Text(
          'ReVYB',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: displayHome(),
    );
  }

  Widget ios() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'ReVYB',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: displayHome(),
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
    return const Placeholder();
  }
}
