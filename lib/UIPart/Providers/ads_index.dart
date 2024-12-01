import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdsIndex extends StateNotifier<int> {
  AdsIndex() : super(0);
  void setIndex(int index) {
    if (index == state) return;
    state = index;
  }
}

final adsIndexProvider = StateNotifierProvider<AdsIndex, int>((_) {
  return AdsIndex();
});
