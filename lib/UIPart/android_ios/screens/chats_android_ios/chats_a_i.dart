import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/buying_chats_android.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/selling_chats_android.dart';

class ChatsAI extends ConsumerStatefulWidget {
  const ChatsAI({super.key});

  @override
  ConsumerState<ChatsAI> createState() => _ChatsAIState();
}

class _ChatsAIState extends ConsumerState<ChatsAI> {
  Widget android() {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 3,
          backgroundColor: Colors.grey[200],
          title: Text(
            'Inbox',
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Column(
          children: [
            TabBar(
              indicatorColor: Colors.blue,
              tabs: [
                Tab(
                  child: Text(
                    'Buying',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                Tab(
                  child: Text(
                    'Selling',
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BuyingChatsAndroid(),
                  SellingChatsAndroid(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ios() {
    return CupertinoPageScaffold(child: SizedBox());
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
