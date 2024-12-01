import 'package:flutter/cupertino.dart';
import 'package:resell/UIPart/IOS_Files/screens/home/display_category_ads.dart';

class FetchCategoryAds extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;
  const FetchCategoryAds(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          subCategoryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: DisplayCategoryAds(
          categoryName: categoryName,
          subCategoryName: subCategoryName,
        ),
      ),
    );
  }
}
