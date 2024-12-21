import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalAdRecIdAdId extends StateNotifier<String?> {
  GlobalAdRecIdAdId() : super(null);
  void setAdId(String id) {
    state = id;
  }

  void clearAdId() {
    state = null;
  }
}

final globalRecIdAdIdProvider = StateNotifierProvider<GlobalAdRecIdAdId, String?>((ref) {
  return GlobalAdRecIdAdId();
});
