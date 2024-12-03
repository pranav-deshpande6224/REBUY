import 'package:flutter/material.dart';

class AboutAndroid extends StatelessWidget {
  const AboutAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 10,
          title: const Text('About'),
        ),
        body: Center(
          child: Text(
            'About',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ));
  }
}
