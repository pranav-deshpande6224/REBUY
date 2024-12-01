import 'package:flutter/cupertino.dart';

class Policies extends StatelessWidget {
  const Policies({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Policies'),
      ),
      child: Center(
        child: Text('Policies'),
      ),
    );
  }
}
