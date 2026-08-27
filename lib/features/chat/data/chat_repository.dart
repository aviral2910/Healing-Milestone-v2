import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/features/chat/data/models/chat_models.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ApiClient _apiClient;

  ChatRepository(this._firestore, this._storage, this._apiClient);

  // --- API Methods for Permissions ---

  Future<String> requestChat(String targetUserId, {bool isMutual = false}) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) throw Exception('Not authenticated');

    final uids = [myUid, targetUserId]..sort();
    final roomId = 'chat_${uids[0]}_${uids[1]}';

    final docRef = _firestore.collection('chat_rooms').doc(roomId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      await docRef.set({
        'participants': [myUid, targetUserId],
        'type': 'peer',
        'status': isMutual ? 'accepted' : 'pending',
        'initiatorId': myUid,
        'lastMessageText': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {
          myUid: 0,
          targetUserId: 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return roomId;
  }

  Future<void> acceptChat(String roomId) async {
    await _firestore.collection('chat_rooms').doc(roomId).update({
      'status': 'accepted',
    });
  }

  Future<void> declineChat(String roomId) async {
    await _firestore.collection('chat_rooms').doc(roomId).update({
      'status': 'declined',
    });
  }

  // --- Firestore Streams ---

  Stream<List<ChatRoom>> watchActiveChats(String myUserId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: myUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).where((r) => r.status == 'accepted' || (r.status == 'pending' && r.initiatorId == myUserId)).toList());
  }

  Stream<List<ChatRoom>> watchPendingRequests(String myUserId) {
    // Rooms where I am a participant, status is pending, but I am NOT the initiator
    // Note: Firestore doesn't support 'not equal' well with arrayContains.
    // We will query where participants contains me, filter status and initiator locally to avoid missing composite indexes.
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: myUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final allPending = snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).where((r) => r.status == 'pending').toList();
      return allPending.where((room) => room.initiatorId != myUserId).toList();
    });
  }
  
  Stream<List<ChatRoom>> watchSentRequests(String myUserId) {
    return _firestore
        .collection('chat_rooms')
        .where('initiatorId', isEqualTo: myUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).where((r) => r.status == 'pending').toList());
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  // --- Sending Messages ---

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    String? text,
    File? imageFile,
    String? sharedJourneyId,
    String? sharedStoryId,
  }) async {
    String? imageUrl;
    
    if (imageFile != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('chats/$roomId/$fileName');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    final messageRef = _firestore.collection('chat_rooms').doc(roomId).collection('messages').doc();
    final now = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      // 1. Create message
      transaction.set(messageRef, {
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'sharedJourneyId': sharedJourneyId,
        'sharedStoryId': sharedStoryId,
        'createdAt': now,
        'readBy': [senderId],
      });

      // 2. Update room snippet
      final roomRef = _firestore.collection('chat_rooms').doc(roomId);
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? '📷 Image' : (sharedJourneyId != null ? '🔗 Shared a Journey' : '🔗 Shared a Story'));

      // 3. We can't do complex FieldValue.increment inside dynamic map easily, 
      // so in a real massive scale app we use a cloud function. 
      // For now we just update snippet.
      transaction.update(roomRef, {
        'lastMessageText': snippet,
        'lastMessageSenderId': senderId,
        'lastMessageTime': now,
      });
    });
  }

  Future<void> markAsRead(String roomId, String myUserId) async {
    // Normally handled by pagination/scroll listener updating individual messages
    // Or just clearing the unread count in the room doc.
  }
  Future<void> deleteMessage(String roomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> deleteChatRoom(String roomId) async {
    // Delete all messages first (batch delete)
    final messages = await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .get();
        
    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the room document itself
    batch.delete(_firestore.collection('chat_rooms').doc(roomId));
    
    await batch.commit();
  }
}
