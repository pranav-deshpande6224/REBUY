import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';

Stream<int> getUnreadCount(String docIdInsideChat, String recieverId) {
  AuthHandler handler = AuthHandler.authHandlerInstance;
  final firestore = handler.fireStore;
  Stream<int> value = firestore
      .collection('users')
      .doc(handler.newUser.user!.uid)
      .collection('chats')
      .doc(docIdInsideChat)
      .collection('messages')
      .where('senderId', isEqualTo: recieverId)
      .where('isSeen', isEqualTo: false)
      .snapshots()
      .map(
    (querySnapshots) {
     return querySnapshots.docs.length;
    },
  );
  return value;
}
