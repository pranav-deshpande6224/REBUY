import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class CategoryAdsState {
  final List<Item> items;
  final bool isLoadingMore;

  CategoryAdsState({
    required this.items,
    this.isLoadingMore = false,
  });
  CategoryAdsState copyWith({
    String? category,
    String? subCategory,
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return CategoryAdsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowCategoryAds extends StateNotifier<AsyncValue<CategoryAdsState>> {
  ShowCategoryAds() : super(const AsyncValue.loading());
  final int _itemsPerPage = 8;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _hasMoreCategory = true;
  bool _isLoadingCategory = false;
  AuthHandler handler = AuthHandler.authHandlerInstance;

  Future<void> fetchInitialItems(String category, String subCategory) async {
    if (_isLoadingCategory) return;
    _isLoadingCategory = true;
    if (handler.newUser.user != null) {
      try {
         final firestore = handler.fireStore;
      Query<Map<String, dynamic>> query = firestore
        .collection('Category')
        .doc(category)
        .collection('Subcategories')
        .doc(subCategory)
        .collection('Ads')
        .orderBy('createdAt', descending: true)
        .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        List<Item> items = [];
        for (var doc in querySnapshot.docs) {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          final item = Item.fromJson(dataDoc.data()!, doc, ref);
          items.add(item);
        }
         if(querySnapshot.docs.isNotEmpty){
            _lastDocument = querySnapshot.docs.last;
          }
          _hasMoreCategory = querySnapshot.docs.length == _itemsPerPage;
         state = AsyncValue.data(CategoryAdsState(items: items));
      } catch (error, stack) {
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoadingCategory = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }

  Future<void> refreshItems(String category, String subCategory) async {
    if (_isLoadingCategory) return;
    _lastDocument = null;
    _hasMoreCategory = true;
    state = const AsyncValue.loading();
    await fetchInitialItems(category, subCategory);
  }

  void resetState() {
    _hasMoreCategory = true;
    _isLoadingCategory = false;
    _lastDocument = null;
    state = const AsyncValue.loading();
  }


  Future<void> fetchMoreItems(String category, String subCategory) async {
    if (_isLoadingCategory ||
        !_hasMoreCategory ||
        state.asData?.value.isLoadingMore == true) {
      return;
    }
    state = AsyncValue.data(state.asData!.value.copyWith(isLoadingMore: true));
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        await Future.delayed(const Duration(seconds: 1));
        Query<Map<String, dynamic>> query = fireStore
            .collection('Category')
            .doc(category)
            .collection('Subcategories')
            .doc(subCategory)
            .collection('Ads')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        List<Item> moreHomeItems =
            await Future.wait(querySnapshot.docs.map((doc) async {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          return Item.fromJson(dataDoc.data()!, doc, ref);
        }).toList());
        if (moreHomeItems.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMoreCategory = moreHomeItems.length == _itemsPerPage;
        state = AsyncValue.data(
          state.asData!.value.copyWith(
            items: [...state.asData!.value.items, ...moreHomeItems],
            isLoadingMore: false,
          ),
        );
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
      }
    } else {
      // TODO Navigate to login screen
    }
  }
}

final showCatAdsProvider =
    StateNotifierProvider<ShowCategoryAds, AsyncValue<CategoryAdsState>>((ref) {
  return ShowCategoryAds();
});
