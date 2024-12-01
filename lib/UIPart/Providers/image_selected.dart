import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelected extends StateNotifier<List<XFile>> {
  ImageSelected() : super([]);
  void addImage(List<XFile> image) {
    state = [...state, ...image];
  }

  void removeImage(XFile image) {
    state = state.where((element) => element != image).toList();
  }

  void reset() {
    state = [];
  }
}

final imageProvider =
    StateNotifierProvider<ImageSelected, List<XFile>>((_) => ImageSelected());
