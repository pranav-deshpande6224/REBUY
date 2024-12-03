import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/old/old_ios/ios_ui/IOS_Files/screens/home/display_home_ads.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'ReVYB',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: const SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DisplayHomeAds(),
            )
          ],
        ),
      ),
    );
  }
}
