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

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final topNavIndexProvider = StateProvider<int>((ref) => 0);


class ChatNotificationData extends StateNotifier<Map<String, String?>> {
  ChatNotificationData() : super({'postedBy': null, 'adId': null});

  void setNotificationData(String? postedBy, String? adId) {
    state = {'postedBy': postedBy, 'adId': adId};
  }

  void clearNotificationData() {
    state = {'postedBy': null, 'adId': null};
  }
}

final chatNotificationProvider = StateNotifierProvider<ChatNotificationData, Map<String, String?>>(
  (ref) => ChatNotificationData(),
);