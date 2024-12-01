import 'package:flutter/material.dart';
import 'package:resell/UIPart/Android_Files/screens/home/display_category_ads_android.dart';

class FetchCategoryAdsAndroid extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;
  const FetchCategoryAdsAndroid(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: Text(
          subCategoryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: DisplayCategoryAdsAndroid(
        categoryName: categoryName,
        subCategoryName: subCategoryName,
      )
    );
  }
}
