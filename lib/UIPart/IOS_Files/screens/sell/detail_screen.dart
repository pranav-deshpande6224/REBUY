
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/IOS_Files/screens/home/fetch_category_ads.dart';
import 'package:resell/UIPart/IOS_Files/screens/sell/product_get_info.dart';

class DetailScreen extends StatelessWidget {
  final String categoryName;
  final List<String> subCategoryList;
  final bool isPostingData;
  const DetailScreen(
      {required this.isPostingData,
      required this.categoryName,
      required this.subCategoryList,
      super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(categoryName),
        previousPageTitle: '',
      ),
      child: ListView.builder(
        itemCount: subCategoryList.length,
        itemBuilder: (ctx, index) {
          return Column(
            children: [
              CupertinoListTile(
                onTap: () {
                  if (isPostingData) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => ProductGetInfo(
                          categoryName: categoryName,
                          subCategoryName: subCategoryList[index],
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => FetchCategoryAds(
                          categoryName: categoryName,
                          subCategoryName: subCategoryList[index],
                        ),
                      ),
                    );
                  }
                },
                trailing: const Icon(
                  CupertinoIcons.right_chevron,
                  color: CupertinoColors.activeBlue,
                ),
                title: Text(
                  subCategoryList[index],
                  style: GoogleFonts.roboto(),
                ),
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey3,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
