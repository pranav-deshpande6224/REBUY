import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class OtherAdState {
  final List<Item> items;
  final bool isLoadingMore;
  OtherAdState({
    required this.items,
    this.isLoadingMore = false,
  });
  OtherAdState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return OtherAdState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowOtherAds extends StateNotifier<AsyncValue<OtherAdState>> {
  ShowOtherAds() : super(const AsyncValue.loading());
  DocumentSnapshot<Map<String, dynamic>>? _lastHomeDocument;
  bool _hasMoreHome = true;
  bool _isLoadingHome = false;
  final int _itemsPerPageOtherAd = 8;
  AuthHandler handler = AuthHandler.authHandlerInstance;
  Future<void> fetchInitialItems() async {
    if (_isLoadingHome) return;
    _isLoadingHome = true;
    if (handler.newUser.user != null) {
      print("before fetching initial items");
      try {
        final firestore = handler.fireStore;
        Query<Map<String, dynamic>> query = firestore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('others')
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPageOtherAd);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        print(querySnapshot.docs.length);
        List<Item> items = [];
        for (var doc in querySnapshot.docs) {
          DocumentReference<Map<String, dynamic>> ref = doc['adReference'];
          DocumentSnapshot<Map<String, dynamic>> dataDoc = await ref.get();
          final item = Item.fromJson(dataDoc.data()!, doc, ref);
          items.add(item);
        }
        print(items.length);
        if (querySnapshot.docs.isNotEmpty) {
          _lastHomeDocument = querySnapshot.docs.last;
        }
        _hasMoreHome = querySnapshot.docs.length == _itemsPerPageOtherAd;
        state = AsyncValue.data(OtherAdState(items: items));
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
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('others')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastHomeDocument!)
            .limit(_itemsPerPageOtherAd);
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
        _hasMoreHome = moreHomeItems.length == _itemsPerPageOtherAd;
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

final otherAdsprovider =
    StateNotifierProvider<ShowOtherAds, AsyncValue<OtherAdState>>((ref) {
  return ShowOtherAds();
});
