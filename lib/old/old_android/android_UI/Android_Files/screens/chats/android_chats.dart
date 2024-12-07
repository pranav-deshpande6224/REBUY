import 'package:flutter/material.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/buying_chats_android.dart';
import 'package:resell/UIPart/android_ios/screens/chats_android_ios/selling_chats_android.dart';

class AndroidChats extends StatefulWidget {
  const AndroidChats({super.key});

  @override
  State<AndroidChats> createState() => _AndroidChatsState();
}

class _AndroidChatsState extends State<AndroidChats> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 10,
          title: const Text('Inbox'),
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
}
