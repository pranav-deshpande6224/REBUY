import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class HomeAdState {
  final List<Item> items;
  final bool isLoadingMore;
  HomeAdState({
    required this.items,
    this.isLoadingMore = false,
  });
  HomeAdState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return HomeAdState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowHomeAds extends StateNotifier<AsyncValue<HomeAdState>> {
  ShowHomeAds() : super(const AsyncValue.loading());
  DocumentSnapshot<Map<String, dynamic>>? _lastHomeDocument;
  bool _hasMoreHome = true;
  bool _isLoadingHome = false;
  final int _itemsPerPageHome = 8;
  AuthHandler handler = AuthHandler.authHandlerInstance;
  Future<void> fetchInitialItems() async {
    if (_isLoadingHome) return;
    _isLoadingHome = true;
    if (handler.newUser.user != null) {
      try {
        final firestore = handler.fireStore;
        Query<Map<String, dynamic>> query =  firestore
            .collection('AllAds')
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPageHome);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
          List<Item> items = [];
          for (var doc in querySnapshot.docs) {
            DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
            DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
            final item = Item.fromJson(dataDoc.data()!, doc, ref);
            items.add(item);
          }
          if(querySnapshot.docs.isNotEmpty){
            _lastHomeDocument = querySnapshot.docs.last;
          }
          _hasMoreHome = querySnapshot.docs.length == _itemsPerPageHome;
         state = AsyncValue.data(HomeAdState(items: items));
      } catch (error, stack) {
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoadingHome = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }

  Future<void> refreshItems() async {
    if (_isLoadingHome) return;
    _lastHomeDocument = null;
    _hasMoreHome = true;
    state = const AsyncValue.loading();
    await fetchInitialItems();
  }

  void resetState() {
    _hasMoreHome = true;
    _isLoadingHome = false;
    _lastHomeDocument = null;
    state = const AsyncValue.loading();
  }

  Future<void> fetchMoreItems() async {
    if (_isLoadingHome ||
        !_hasMoreHome ||
        state.asData?.value.isLoadingMore == true) {
      return;
    }
    state = AsyncValue.data(state.asData!.value.copyWith(isLoadingMore: true));
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        await Future.delayed(const Duration(seconds: 1));
        Query<Map<String, dynamic>> query = fireStore
            .collection('AllAds')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastHomeDocument!)
            .limit(_itemsPerPageHome);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        List<Item> moreHomeItems =
            await Future.wait(querySnapshot.docs.map((doc) async {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          return Item.fromJson(dataDoc.data()!, doc, ref);
        }).toList());
        if (moreHomeItems.isNotEmpty) {
          _lastHomeDocument = querySnapshot.docs.last;
        }
        _hasMoreHome = moreHomeItems.length == _itemsPerPageHome;
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

final homeAdsprovider =
    StateNotifierProvider<ShowHomeAds, AsyncValue<HomeAdState>>((ref) {
  return ShowHomeAds();
});
