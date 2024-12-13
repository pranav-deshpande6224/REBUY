import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkAsFavProvider extends StateNotifier<bool> {
  MarkAsFavProvider() : super(false);
  void markAsFav() {
    state = true;
  }

  void unMarkAsFav() {
    state = false;
  }
}

final favProvider =
    StateNotifierProvider<MarkAsFavProvider, bool>((_) => MarkAsFavProvider());
