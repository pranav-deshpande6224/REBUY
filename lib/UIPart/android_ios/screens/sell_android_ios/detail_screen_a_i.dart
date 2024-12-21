import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/screens/home_android_ios/fetch_category_ads_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/sell_android_ios/product_get_info_a_i.dart';

class DetailScreenAI extends StatelessWidget {
  final String categoryName;
  final List<String> subCategoryList;
  final bool isPostingData;
  const DetailScreenAI(
      {required this.isPostingData,
      required this.categoryName,
      required this.subCategoryList,
      super.key});
  Widget body(BuildContext context) {
    if (Platform.isAndroid) {
      return ListView.separated(
        itemBuilder: (ctx, index) {
          return ListTile(
            onTap: () {
              if (isPostingData) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ProductGetInfoAI(
                      categoryName: categoryName,
                      subCategoryName: subCategoryList[index],
                    ),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => FetchCategoryAdsAI(
                      categoryName: categoryName,
                      subCategoryName: subCategoryList[index],
                    ),
                  ),
                );
              }
            },
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
            ),
            title: Text(
              subCategoryList[index],
              style: GoogleFonts.lato(),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            thickness: 0.5,
            color: Colors.black,
          );
        },
        itemCount: subCategoryList.length,
      );
    } else if (Platform.isIOS) {
      return ListView.separated(
        itemBuilder: (ctx, index) {
          return CupertinoListTile(
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              if (isPostingData) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (ctx) => ProductGetInfoAI(
                      categoryName: categoryName,
                      subCategoryName: subCategoryList[index],
                    ),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (ctx) => FetchCategoryAdsAI(
                      categoryName: categoryName,
                      subCategoryName: subCategoryList[index],
                    ),
                  ),
                );
              }
            },
            title: Text(
              subCategoryList[index],
              style: GoogleFonts.lato(),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            width: double.infinity,
            height: 0.5,
            decoration: BoxDecoration(
              border: Border.all(
                color: CupertinoColors.systemGrey,
              ),
            ),
          );
        },
        itemCount: subCategoryList.length,
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 3,
          backgroundColor: Colors.grey[200],
          title: Text(
            categoryName,
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: body(context),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(categoryName, style: GoogleFonts.lato()),
          previousPageTitle: '',
        ),
        child: body(context),
      );
    }
    return const SizedBox();
  }
}
