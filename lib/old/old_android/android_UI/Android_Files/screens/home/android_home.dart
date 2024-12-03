import 'package:flutter/material.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/home/display_home_android.dart';

class AndroidHome extends StatefulWidget {
  const AndroidHome({super.key});

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: const Text('ReVYB'),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DisplayHomeAndroid(),
            )
          ],
        ),
      ),
            );
  }
}
