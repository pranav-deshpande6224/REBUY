import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectAnItem extends StateNotifier<int> {
  SelectAnItem() : super(-1);
  void updateSelectedItem(int index) {
    state = index;
  }
}

final selectedIpadProvider = StateNotifierProvider<SelectAnItem, int>(
  (ref) => SelectAnItem(),
);

final selectChargerProvider = StateNotifierProvider<SelectAnItem, int>(
  (ref) => SelectAnItem(),
);
