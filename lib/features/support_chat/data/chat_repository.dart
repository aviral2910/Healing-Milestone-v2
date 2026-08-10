import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:healing_milestones/features/support_chat/data/api_chat_repository.dart';

import 'models/chat_model.dart';
import 'models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ChatRepository(this._firestore, this._storage);

  Future<String> getOrCreateSupportChat(String userId) async {
    final query = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    try {
      final existingChat = query.docs.firstWhere((doc) {
        final data = doc.data();
        return data['type'] == 'support';
      });
      return existingChat.id;
    } catch (e) {
      // No existing support chat found, proceed to create
    }

    final newChatRef = _firestore.collection('chats').doc();
    final newChat = ChatModel(
      id: newChatRef.id,
      participants: [userId, 'admin'],
      type: 'support',
      lastMessage: '',
      lastUpdated: DateTime.now(),
      unreadCount: {userId: 0, 'admin': 0},
      typingStatus: {userId: false, 'admin': false},
    );

    await newChatRef.set(newChat.toMap());
    return newChatRef.id;
  }

  Stream<ChatModel?> getChatStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ChatModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> sendMessage(String chatId, MessageModel message, {String? recipientId}) async {
    final batch = _firestore.batch();
    
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id);
        
    final chatRef = _firestore.collection('chats').doc(chatId);

    batch.set(messageRef, message.toMap());
    
    // Determine last message text
    String lastMessageText = message.text;
    if (message.messageType == 'image' && lastMessageText.isEmpty) {
      lastMessageText = 'Image sent';
    }

    final updates = <String, dynamic>{
      'lastMessage': lastMessageText,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (recipientId != null) {
      updates['unreadCount.$recipientId'] = FieldValue.increment(1);
    }

    batch.update(chatRef, updates);

    await batch.commit();
  }

  Future<void> clearUnreadCount(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });
  }

  Future<void> updateTypingStatus(String chatId, String userId, bool isTyping) async {
    await _firestore.collection('chats').doc(chatId).update({
      'typingStatus.$userId': isTyping,
    });
  }

  Future<String> uploadImage(String chatId, File imageFile) async {
    final fileName = const Uuid().v4();
    final ref = _storage.ref().child('chats/$chatId/$fileName');
    
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}

final chatRepositoryProvider = Provider<ApiChatRepository>((ref) {
  return ref.watch(apiChatRepositoryProvider);
});
