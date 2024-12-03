import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/display_category_ads_a_i.dart';

class FetchCategoryAdsAI extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;
  const FetchCategoryAdsAI(
      {required this.categoryName, required this.subCategoryName, super.key});
  Widget body() {
    return SafeArea(
      child: DisplayCategoryAdsAI(
        categoryName: categoryName,
        subCategoryName: subCategoryName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 10,
          title: Text(
            subCategoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(),
          ),
        ),
        body: body(),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            style: GoogleFonts.roboto(),
            subCategoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          previousPageTitle: 'Back',
        ),
        child: body(),
      );
    }
    return const Placeholder();
  }
}
