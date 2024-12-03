import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/IOS_Files/screens/sell/sell.dart';
import 'package:resell/UIPart/android_ios/model/category.dart';
import 'package:resell/UIPart/android_ios/screens/sell_android_ios/detail_screen_a_i.dart';
import 'package:resell/constants/constants.dart';

class SellAI extends StatefulWidget {
  const SellAI({super.key});

  @override
  State<SellAI> createState() => _SellAIState();
}

class _SellAIState extends State<SellAI> {
  final List<SellCategory> categoryList = [
    SellCategory(
        icon: Platform.isAndroid
            ? Icons.phone
            : Platform.isIOS
                ? CupertinoIcons.phone
                : Icons.photo,
        categoryTitle: Constants.mobileandTab,
        subCategory: [
          Constants.mobilePhone,
          Constants.tablet,
          Constants.earphoneHeadPhoneSpeakers,
          Constants.smartWatches,
          Constants.mobileChargerLaptopCharger
        ]),
    SellCategory(
        icon: Platform.isAndroid
            ? Icons.laptop
            : Platform.isIOS
                ? CupertinoIcons.device_laptop
                : Icons.photo,
        categoryTitle: Constants.latopandmonitor,
        subCategory: [
          Constants.laptop,
          Constants.monitor,
          Constants.laptopAccessories
        ]),
    const SellCategory(
      icon: Icons.pedal_bike,
      categoryTitle: Constants.cycleandAccessory,
      subCategory: [Constants.cycle, Constants.cycleAccesory],
    ),
    SellCategory(
      icon: Platform.isAndroid
          ? Icons.domain
          : Platform.isIOS
              ? CupertinoIcons.building_2_fill
              : Icons.photo,
      categoryTitle: Constants.hostelAccesories,
      subCategory: [
        Constants.whiteBoard,
        Constants.bedPillowCushions,
        Constants.backPack,
        Constants.bottle,
        Constants.trolley,
        Constants.wheelChair,
        Constants.curtain
      ],
    ),
    SellCategory(
      icon: Platform.isAndroid
          ? Icons.book
          : Platform.isIOS
              ? CupertinoIcons.book
              : Icons.photo,
      categoryTitle: Constants.booksandSports,
      subCategory: [
        Constants.booksSubCat,
        Constants.gym,
        Constants.musical,
        Constants.sportsEquipment
      ],
    ),
    SellCategory(
      icon: Platform.isAndroid
          ? Icons.tv
          : Platform.isIOS
              ? CupertinoIcons.tv
              : Icons.photo,
      categoryTitle: Constants.electronicandAppliances,
      subCategory: [
        Constants.calculator,
        Constants.hddSSD,
        Constants.router,
        Constants.tripod,
        Constants.ironBox,
        Constants.camera
      ],
    ),
    SellCategory(
      icon: Platform.isAndroid
          ? Icons.person_2_rounded
          : Platform.isIOS
              ? CupertinoIcons.person_crop_circle
              : Icons.photo,
      categoryTitle: Constants.fashion,
      subCategory: [
        Constants.mensFashion,
        Constants.womensFashion,
      ],
    ),
  ];

  Widget body() {
    return SafeArea(
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
                if (Platform.isAndroid) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => DetailScreenAI(
                        categoryName: category.categoryTitle,
                        subCategoryList: category.subCategory,
                        isPostingData: true,
                      ),
                    ),
                  );
                } else if (Platform.isIOS) {
                  Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute(
                      builder: (ctx) => DetailScreenAI(
                        categoryName: category.categoryTitle,
                        subCategoryList: category.subCategory,
                        isPostingData: true,
                      ),
                    ),
                  );
                }
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
            'What are you selling?',
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
            'What are you selling?',
            style: GoogleFonts.roboto(),
          ),
        ),
        child: body(),
      );
    }
    return const SizedBox();
  }
}
