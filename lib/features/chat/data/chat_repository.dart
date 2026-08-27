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
    String? sharedProfileId,
    bool isViewOnce = false,
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
      // 1. READ FIRST: Firestore requires all reads to happen before writes in a transaction
      final roomRef = _firestore.collection('chat_rooms').doc(roomId);
      final roomDoc = await transaction.get(roomRef);
      
      // 2. WRITE message
      transaction.set(messageRef, {
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'sharedJourneyId': sharedJourneyId,
        'sharedStoryId': sharedStoryId,
        'sharedProfileId': sharedProfileId,
        'createdAt': now,
        'readBy': [senderId],
      });

      // 3. WRITE room update
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? (isViewOnce ? '⏱️ View Once Photo' : '📷 Image') : (sharedJourneyId != null ? '🔗 Shared a Journey' : (sharedStoryId != null ? '🔗 Shared a Post' : '👤 Shared a Profile')));

      if (roomDoc.exists) {
        final data = roomDoc.data();
        final participants = List<String>.from(data?['participants'] ?? []);
        
        final updates = <String, dynamic>{
          'lastMessageText': snippet,
          'lastMessageSenderId': senderId,
          'lastMessageTime': now,
        };

        for (final p in participants) {
          if (p != senderId) {
            updates['unreadCount.$p'] = FieldValue.increment(1);
          }
        }
        
        transaction.update(roomRef, updates);
      }
    });
  }

  Future<void> markMessageAsViewed(String roomId, String messageId) async {
    final docRef = _firestore.collection('chat_rooms').doc(roomId).collection('messages').doc(messageId);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['imageUrl'] != null) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          print("Error deleting view-once image from storage: $e");
        }
      }
    }

    await docRef.update({
      'isViewed': true,
      'imageUrl': FieldValue.delete(),
    });
  }

  Future<void> markAsRead(String roomId, String myUserId) async {
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    await roomRef.update({
      'unreadCount.$myUserId': 0,
    });
  }
  Future<void> deleteMessage(String roomId, String messageId) async {
    final docRef = _firestore.collection('chat_rooms').doc(roomId).collection('messages').doc(messageId);
    final doc = await docRef.get();
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['imageUrl'] != null) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          print("Error deleting image from storage: $e");
        }
      }
    }
    
    await docRef.delete();

    // Update lastMessageText in chat_rooms document
    final latestMessages = await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (latestMessages.docs.isNotEmpty) {
      final latestDoc = latestMessages.docs.first;
      final msgData = latestDoc.data();
      final text = msgData['text'] as String?;
      final imageUrl = msgData['imageUrl'] as String?;
      final isViewOnce = msgData['isViewOnce'] as bool? ?? false;
      final sharedJourneyId = msgData['sharedJourneyId'] as String?;
      final sharedStoryId = msgData['sharedStoryId'] as String?;
      final sharedProfileId = msgData['sharedProfileId'] as String?;

      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? (isViewOnce ? '⏱️ View Once Photo' : '📷 Image') : (sharedJourneyId != null ? '🔗 Shared a Journey' : (sharedStoryId != null ? '🔗 Shared a Post' : (sharedProfileId != null ? '👤 Shared a Profile' : ''))));

      await _firestore.collection('chat_rooms').doc(roomId).update({
        'lastMessageText': snippet,
        'lastMessageSenderId': msgData['senderId'],
        'lastMessageTime': msgData['createdAt'],
      });
    } else {
      await _firestore.collection('chat_rooms').doc(roomId).update({
        'lastMessageText': '',
        'lastMessageSenderId': null,
      });
    }
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
      final data = doc.data();
      if (data['imageUrl'] != null) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          print("Error deleting image from storage during room deletion: $e");
        }
      }
      batch.delete(doc.reference);
    }
    
    // Delete the room document itself
    batch.delete(_firestore.collection('chat_rooms').doc(roomId));
    
    await batch.commit();
  }
}

