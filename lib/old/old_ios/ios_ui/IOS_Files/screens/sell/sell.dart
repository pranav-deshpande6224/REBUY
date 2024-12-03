
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/old/old_ios/ios_ui/IOS_Files/screens/sell/detail_screen.dart';
import 'package:resell/constants/constants.dart';



class Sell extends StatefulWidget {
  const Sell({super.key});

  @override
  State<Sell> createState() => _SellState();
}

class _SellState extends State<Sell> {
  final List<SellCategory> categoryList = const [
    SellCategory(
        icon: CupertinoIcons.phone,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: CupertinoIcons.device_laptop,
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
        icon: CupertinoIcons.building_2_fill,
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
      icon: CupertinoIcons.book,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
        icon: CupertinoIcons.tv,
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
      icon: CupertinoIcons.person_crop_circle,
      categoryTitle: Constants.fashion,
      subCategory: [
        Constants.mensFashion,
        Constants.womensFashion,
      ],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'What are you selling?',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
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
                    CupertinoPageRoute(
                      builder: (ctx) => DetailScreen(
                        categoryName: category.categoryTitle,
                        subCategoryList: category.subCategory,
                        isPostingData: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 35,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FittedBox(
                          child: Text(
                            category.categoryTitle,
                            style: GoogleFonts.roboto(
                              color: CupertinoColors.white,
                              fontSize: 16,
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
