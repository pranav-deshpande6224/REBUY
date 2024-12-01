import 'package:flutter_riverpod/flutter_riverpod.dart';

class SegmentedControlProvider extends StateNotifier<String> {
  SegmentedControlProvider() : super('buying');
  void changeSegment(String value) {
    state = value;
  }
}

final segmentedControlProvider =
    StateNotifierProvider<SegmentedControlProvider, String>(
  (ref) => SegmentedControlProvider(),
);
