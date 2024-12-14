import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';

enum FavouriteState {
  loading,
  favourite,
  notFavourite,
}

class FavouriteNotifier extends StateNotifier<FavouriteState> {
  FavouriteNotifier() : super(FavouriteState.loading);
  AuthHandler handler = AuthHandler.authHandlerInstance;


  void resetState() {
    state = FavouriteState.loading;
  }

  Future<void> checkFavourite(
      DocumentReference<Map<String, dynamic>> adReference) async {
    state = FavouriteState.loading;
    try {
      final fireStore = handler.fireStore;
      final favouriteCollection = fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('favourites');
      final querySnapshot = await favouriteCollection
          .where('adReference', isEqualTo: adReference)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        state = FavouriteState.favourite;
      } else {
        state = FavouriteState.notFavourite;
      }
    } catch (e) {
      state = FavouriteState.notFavourite;
    }
  }

  Future<void> toggleFavourite(
      DocumentReference<Map<String, dynamic>> adReference,
      BuildContext favContext) async {
    try {
      final fireStore = handler.fireStore;
      final favouriteCollection = fireStore
          .collection('users')
          .doc(handler.newUser.user!.uid)
          .collection('favourites');
      if (state == FavouriteState.favourite) {
        // Remove from favourites
        final querySnapshot = await favouriteCollection
            .where('adReference', isEqualTo: adReference)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          await favouriteCollection.doc(querySnapshot.docs.first.id).delete();
          state = FavouriteState.notFavourite;
        }
      } else if (state == FavouriteState.notFavourite) {
        // Add to favourites
        await favouriteCollection.add({
          'adReference': adReference,
          'createdAt': FieldValue.serverTimestamp(),
        });
        state = FavouriteState.favourite;
      }
      Navigator.of(favContext).pop();
    } catch (e) {
      Navigator.of(favContext).pop();
      state = FavouriteState.notFavourite;
    }
  }
}

final favouriteProvider =
    StateNotifierProvider<FavouriteNotifier, FavouriteState>(
  (ref) => FavouriteNotifier(),
);
