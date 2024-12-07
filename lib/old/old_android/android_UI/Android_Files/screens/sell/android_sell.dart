
import 'package:flutter/material.dart';
import 'package:resell/old/old_android/android_UI/Android_Files/screens/sell/android_detail_screen.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/constants/constants.dart';

class AndroidSell extends StatefulWidget {
  const AndroidSell({super.key});

  @override
  State<AndroidSell> createState() => _AndroidSellState();
}

class _AndroidSellState extends State<AndroidSell> {
  final List<SellCategory> categoryList = const [
    SellCategory(
        icon: Icons.phone,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: Icons.laptop,
        categoryTitle: Constants.latopandmonitor,
        subCategory: [
          Constants.laptop,
          Constants.monitor,
          Constants.laptopAccessories
        ]),
    SellCategory(
      icon: Icons.pedal_bike,
      categoryTitle: Constants.cycleandAccessory,
      subCategory: [Constants.cycle, Constants.cycleAccesory],
    ),
    SellCategory(
        icon: Icons.domain,
        categoryTitle: Constants.hostelAccesories,
        subCategory: [
          Constants.whiteBoard,
          Constants.bedPillowCushions,
          Constants.backPack,
          Constants.bottle,
          Constants.trolley,
          Constants.wheelChair,
          Constants.curtain
        ]),
    SellCategory(
      icon: Icons.book,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
        icon: Icons.tv,
        categoryTitle: Constants.electronicandAppliances,
        subCategory: [
          Constants.calculator,
          Constants.hddSSD,
          Constants.router,
          Constants.tripod,
          Constants.ironBox,
          Constants.camera
        ]),
    SellCategory(
      icon: Icons.person_2_rounded,
      categoryTitle: Constants.fashion,
      subCategory: [
        Constants.mensFashion,
        Constants.womensFashion,
      ],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: const Text('What are you selling?'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            itemCount: categoryList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemBuilder: (ctx, index) {
              final category = categoryList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (ctx) => AndroidDetailScreen(
                        categoryName: category.categoryTitle,
                        subCategoryList: category.subCategory,
                        isPostingData: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 35,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FittedBox(
                          child: Text(
                            category.categoryTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
