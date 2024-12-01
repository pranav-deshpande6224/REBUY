import 'package:flutter/material.dart';
import 'package:resell/UIPart/Android_Files/screens/home/fetch_category_ads_android.dart';
import 'package:resell/UIPart/Android_Files/screens/sell/product_get_info_android.dart';

class AndroidDetailScreen extends StatelessWidget {
  final String categoryName;
  final List<String> subCategoryList;
  final bool isPostingData;
  const AndroidDetailScreen(
      {required this.categoryName,
      required this.subCategoryList,
      required this.isPostingData,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: Text(categoryName),
      ),
      body: ListView.builder(
        itemCount: subCategoryList.length,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              if (isPostingData) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ProductGetInfoAndroid(
                      categoryName: categoryName,
                      subCategoryName: subCategoryList[index],
                    ),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => FetchCategoryAdsAndroid(
                      categoryName: categoryName,
                      subCategoryName: subCategoryList[index],
                    ),
                  ),
                );
              }
            },
            child: Column(
              children: [
                ListTile(
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                  ),
                  title: Text(
                    subCategoryList[index],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
