import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

class ActiveAdsState {
  final List<Item> items;
  final bool isLoadingMore;
  ActiveAdsState({
    required this.items,
    this.isLoadingMore = false,
  });
  ActiveAdsState copyWith({
    List<Item>? items,
    bool? isLoadingMore,
  }) {
    return ActiveAdsState(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ShowActiveAds extends StateNotifier<AsyncValue<ActiveAdsState>> {
  ShowActiveAds() : super(const AsyncValue.loading());

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final int _itemsPerPage = 5;
  AuthHandler handler = AuthHandler.authHandlerInstance;

  Future<void> fetchInitialItems() async {
    if (_isLoading) return;
    _isLoading = true;
    final fireStore = handler.fireStore;
    if (handler.newUser.user != null) {
      try {
        Query<Map<String, dynamic>> query = fireStore
            .collection('users')
            .doc(handler.newUser.user!.uid)
            .collection('MyActiveAds')
            .where('isAvailable', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(_itemsPerPage);

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        final docs = querySnapshot.docs.map<Item>((doc) {
          return Item.fromJson(doc.data(), doc, doc.reference);
        }).toList();
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMore = querySnapshot.docs.length == _itemsPerPage;
        state = AsyncValue.data(ActiveAdsState(items: docs));
      } catch (error, stack) {
        print(error);
        state = AsyncValue.error(error, stack);
      } finally {
        _isLoading = false;
      }
    } else {
      // TODO Handle the case when the user is not authenticated
      return;
    }
  }

  Future<void> refreshItems() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests
    _lastDocument = null;
    _hasMore = true;
    state = const AsyncValue.loading();
    await fetchInitialItems();
  }

  void resetState() {
    _hasMore = true;
    _isLoading = false;
    _lastDocument = null;
    state = const AsyncValue.loading();
  }

  Future<void> fetchMoreItems() async {
    if (_isLoading || !_hasMore || state.asData?.value.isLoadingMore == true) {
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
            .collection('MyActiveAds')
            .where('isAvailable', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(_itemsPerPage);
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
        final newDocs = querySnapshot.docs.map<Item>((doc) {
          return Item.fromJson(doc.data(), doc, doc.reference);
        }).toList();
        if (newDocs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }
        _hasMore = newDocs.length == _itemsPerPage;
        state = AsyncValue.data(
          state.asData!.value.copyWith(
            items: [...state.asData!.value.items, ...newDocs],
            isLoadingMore: false,
          ),
        );
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
      }
    } else {
      // TODO NAvigate to login screen
    }
  }

  void deleteItem(Item item) {
    state = AsyncValue.data(state.asData!.value.copyWith(
        items: state.asData!.value.items.where((element) {
      return element.id != item.id;
    }).toList()));
  }
}

final showActiveAdsProvider =
    StateNotifierProvider<ShowActiveAds, AsyncValue<ActiveAdsState>>((ref) {
  return ShowActiveAds();
});
