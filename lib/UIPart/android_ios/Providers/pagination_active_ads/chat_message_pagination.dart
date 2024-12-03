// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:college_project/Authentication/handlers/auth_handler.dart';
// import 'package:college_project/UIPart/IOS_Files/model/message.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final newMessagesProvider =
//     StreamProvider.family<List<Message>, String>((ref, reciever) {
//   return getMessages(recieverId,itemId);
// });

// Stream<List<Message>> getMessages(String recieverId, String itemId) {
//   final handler = AuthHandler.authHandlerInstance;
//   return handler.fireStore
//       .collection('users')
//       .doc(handler.newUser.user!.uid)
//       .collection('chats')
//       .doc("${recieverId}_$itemId")
//       .collection('messages')
//       .orderBy('timeSent', descending: true)
//       .snapshots()
//       .map((snapshot) {
//     return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
//   });

//   // handler.fireStore
//   //       .collection('users')
//   //       .doc(handler.newUser.user!.uid)
//   //       .collection('chats')
//   //       .doc("${receiverId}_$itemid")
//   //       .collection('messages')
//   //       .orderBy('timeSent', descending: false)
//   //       .snapshots()
// }

// final chatProvider =
//     StateNotifierProvider.family<ChatNotifier, List<Message>, String>(
//         (ref, chatId) {
//   return ChatNotifier(chatId);
// });

// class ChatNotifier extends StateNotifier<List<Message>> {
//   ChatNotifier(this.chatId) : super([]) {
//     loadInitialMessages();
//   }
//   final String chatId;
//   final int _messagesPerPage = 20;
//   DocumentSnapshot? _lastMessageSnapshot;
//   bool _hasMoreMessages = true;
//   bool _isLoading = false;
//   AuthHandler handler = AuthHandler.authHandlerInstance;


//   Future<void> loadInitialMessages() async {
//     if (_isLoading) return;
//     _isLoading = true;
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(handler.newUser.user!.uid)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timeSent', descending: true)
//         .limit(_messagesPerPage)
//         .get();

//     final messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
//     state = messages;
//     _lastMessageSnapshot = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
//     _hasMoreMessages = snapshot.docs.length == _messagesPerPage;
//     _isLoading = false;
//   }
//   Future<void> loadMoreMessages() async {
//     if (_isLoading || !_hasMoreMessages || _lastMessageSnapshot == null) return;

//     _isLoading = true;
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(handler.newUser.user!.uid)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timeSent', descending: true)
//         .startAfterDocument(_lastMessageSnapshot!)
//         .limit(_messagesPerPage)
//         .get();

//     final newMessages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
//     state = [...state, ...newMessages];
//     _lastMessageSnapshot = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
//     _hasMoreMessages = snapshot.docs.length == _messagesPerPage;
//     _isLoading = false;
//   }
// }
