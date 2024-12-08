import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/model/message.dart';

class ChatParams {
  final String userId;
  final String receiverId;
  final String itemId;
  ChatParams({
    required this.userId,
    required this.receiverId,
    required this.itemId,
  });
}

class MessagesState {
  final List<Message> messages;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  MessagesState({
    required this.messages,
    this.lastDocument,
    this.hasMore = true,
  });

  MessagesState copyWith({
    List<Message>? messages,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ShowMessageData extends StateNotifier<AsyncValue<MessagesState>> {
  final String userId;
  final String receiverId;
  final String itemId;
  final int pageSize;
  AuthHandler handler = AuthHandler.authHandlerInstance;
  StreamSubscription? _streamSubscription;

  ShowMessageData({
    required this.userId,
    required this.receiverId,
    required this.itemId,
    this.pageSize = 12, 
  }) : super(const AsyncValue.loading()) {
    _listenToNewMessages();
  }

  Future<void> fetchInitialMessages() async {
    state = const AsyncValue.loading();

    try {
      final query = handler.fireStore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc("${receiverId}_$itemId")
          .collection('messages')
          .orderBy('timeSent', descending: true)
          .limit(pageSize);

      final snapshot = await query.get();
      final messages =
          snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();

      state = AsyncValue.data(MessagesState(
        messages: messages,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == pageSize,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> fetchMoreMessages() async {
    if (!state.hasValue || state.isLoading) return;

    final currentState = state.value!;
    if (!currentState.hasMore) return;

    try {
      final query = handler.fireStore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc("${receiverId}_$itemId")
          .collection('messages')
          .orderBy('timeSent', descending: true)
          .startAfterDocument(currentState.lastDocument!)
          .limit(pageSize);

      final snapshot = await query.get();
      final newMessages = snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();

      state = AsyncValue.data(currentState.copyWith(
        messages: [...currentState.messages, ...newMessages],
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == pageSize,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void _listenToNewMessages() {
    final query = handler.fireStore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc("${receiverId}_$itemId")
        .collection('messages')
        .orderBy('timeSent', descending: false);

    _streamSubscription = query.snapshots().listen((snapshot) {
      final newMessages = snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.added)
          .map((change) => Message.fromJson(change.doc.data() as Map<String, dynamic>))
          .toList();

      if (newMessages.isNotEmpty) {
        if (state.hasValue) {
          final currentState = state.value!;
          state = AsyncValue.data(currentState.copyWith(
            messages: [...newMessages, ...currentState.messages],
          ));
        }
      }
    });
  }
  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

final messagesProvider =
    StateNotifierProvider.family<ShowMessageData, AsyncValue<MessagesState>, ChatParams>(
  (ref, params) {
    return ShowMessageData(
      userId: params.userId,
      receiverId: params.receiverId,
      itemId: params.itemId,
    );
  },
);
