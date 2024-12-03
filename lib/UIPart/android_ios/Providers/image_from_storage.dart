import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageFromStorage extends StateNotifier<List<String>> {
  ImageFromStorage() : super([]);

  void showExistingImages(List<String> images) {
    state = [...state, ...images];
  }

  void removeImage(String image) {
    state = state.where((element) => element != image).toList();
  }

  void reset() {
    state = [];
  }
}

final imageFromStorageProvider =
    StateNotifierProvider<ImageFromStorage, List<String>>(
  (_) => ImageFromStorage(),
);
