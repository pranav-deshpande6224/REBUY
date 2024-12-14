import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class FavouriteAdState {
  final List<Item> items;
  final bool isLoadingMore;
  FavouriteAdState({
    required this.items,
    this.isLoadingMore = false,
  });
  FavouriteAdState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return FavouriteAdState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowFavouriteAds extends StateNotifier<AsyncValue<FavouriteAdState>> {
  ShowFavouriteAds() : super(const AsyncValue.loading());
  DocumentSnapshot<Map<String, dynamic>>? _lastFavouriteDocument;
  bool _hasMoreFavourite = true;
  bool _isLoadingFavourite = false;
  final int _itemsPerPageFavourite = 8;
  AuthHandler handler = AuthHandler.authHandlerInstance;

  Future<void> fetchInitialItems() async {
    if (_isLoadingFavourite) return;
    _isLoadingFavourite = true;

    try {
      final firestore = handler.fireStore;
      Query<Map<String, dynamic>> query = firestore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('favourites')
          .orderBy('createdAt', descending: true)
          .limit(_itemsPerPageFavourite);
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      List<Item> items = [];
      for (var doc in querySnapshot.docs) {
        DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
        DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
        final item = Item.fromJson(dataDoc.data()!, doc, ref);
        items.add(item);
      }
      if (querySnapshot.docs.isNotEmpty) {
        _lastFavouriteDocument = querySnapshot.docs.last;
      }
      _hasMoreFavourite = querySnapshot.docs.length == _itemsPerPageFavourite;
      state = AsyncValue.data(FavouriteAdState(items: items));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    } finally {
      _isLoadingFavourite = false;
    }
  }

  Future<void> refreshItems() async {
    if (_isLoadingFavourite) return;
    _lastFavouriteDocument = null;
    _hasMoreFavourite = true;
    state = const AsyncValue.loading();
    await fetchInitialItems();
  }

  void resetState() {
    _hasMoreFavourite = true;
    _isLoadingFavourite = false;
    _lastFavouriteDocument = null;
    state = const AsyncValue.loading();
  }

  Future<void> fetchMoreItems() async {
    if (_isLoadingFavourite ||
        !_hasMoreFavourite ||
        state.asData?.value.isLoadingMore == true) {
      return;
    }
    state = AsyncValue.data(state.asData!.value.copyWith(isLoadingMore: true));
    final fireStore = handler.fireStore;

    try {
      await Future.delayed(const Duration(seconds: 1));
      Query<Map<String, dynamic>> query = fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('favourites')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastFavouriteDocument!)
          .limit(_itemsPerPageFavourite);
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      List<Item> moreFavouriteItems =
          await Future.wait(querySnapshot.docs.map((doc) async {
        DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
        DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
        return Item.fromJson(dataDoc.data()!, doc, ref);
      }).toList());
      if (moreFavouriteItems.isNotEmpty) {
        _lastFavouriteDocument = querySnapshot.docs.last;
      }
      _hasMoreFavourite = moreFavouriteItems.length == _itemsPerPageFavourite;
      state = AsyncValue.data(
        state.asData!.value.copyWith(
          items: [...state.asData!.value.items, ...moreFavouriteItems],
          isLoadingMore: false,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final favouriteAdsProvider = 
 StateNotifierProvider<ShowFavouriteAds, AsyncValue<FavouriteAdState>>((ref) {
  return ShowFavouriteAds();
});

