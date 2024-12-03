import 'package:flutter/material.dart';

class PoliciesAndroid extends StatelessWidget {
  const PoliciesAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: const Text('Policies'),
      ),
      body: const Center(
        child: Text('Policies'),
      ),
    );
  }
}
