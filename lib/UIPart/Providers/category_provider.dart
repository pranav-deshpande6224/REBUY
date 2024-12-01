import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/UIPart/IOS_Files/model/category.dart';

class CategoryProvider extends StateNotifier<FetchCatAndSubCat> {
  CategoryProvider() : super(FetchCatAndSubCat(category: '', subCategory: ''));
  void setCategoryAndSubCategory(String category, String subCategory) {
    state = FetchCatAndSubCat(category: category, subCategory: subCategory);
  }
}

final categoryAndSubCatProvider =
    StateNotifierProvider<CategoryProvider, FetchCatAndSubCat>(
  (ref) => CategoryProvider(),
);
