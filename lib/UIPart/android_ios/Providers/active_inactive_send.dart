import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveInactiveSend extends StateNotifier<bool> {
  ActiveInactiveSend() : super(false);
  void setActiveInactive(bool value) {
    state = value;
  }

  void reset() {
    state = false;
  }
}

final activeInactiveSendProvider =
    StateNotifierProvider<ActiveInactiveSend, bool>(
  (_) {
    return ActiveInactiveSend();
  },
);
