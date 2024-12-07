import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectImage extends StateNotifier<int> {
  SelectImage() : super(0);
  void changeIndex(int index) {
    state = index;
  }
}

final imageSelectProvider =
    StateNotifierProvider<SelectImage, int>((_) => SelectImage());
