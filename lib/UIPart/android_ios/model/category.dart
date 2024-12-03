import 'package:flutter/cupertino.dart';

class SellCategory {
  final IconData icon;
  final String categoryTitle;
  final List<String> subCategory;
  const SellCategory(
      {required this.icon,
      required this.categoryTitle,
      required this.subCategory});
}

class ProfileCategory {
  final IconData icon;
  final String title;
  const ProfileCategory({
    required this.icon,
    required this.title
  });
}


class FetchCatAndSubCat {
  final String category;
  final String subCategory;
  const FetchCatAndSubCat({
    required this.category,
    required this.subCategory
  });
}
