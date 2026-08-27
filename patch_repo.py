import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

# 1. Update sendMessage transaction
old_tx = """      // 2. Update room snippet
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
    });"""

new_tx = """      // 2. Update room snippet & unread counts
      final roomRef = _firestore.collection('chat_rooms').doc(roomId);
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? '📷 Image' : (sharedJourneyId != null ? '🔗 Shared a Journey' : '🔗 Shared a Story'));

      final roomDoc = await transaction.get(roomRef);
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
    });"""

content = content.replace(old_tx, new_tx)

# 2. Update markAsRead
old_mark = """  Future<void> markAsRead(String roomId, String myUserId) async {
    // Normally handled by pagination/scroll listener updating individual messages
    // Or just clearing the unread count in the room doc.
  }"""

new_mark = """  Future<void> markAsRead(String roomId, String myUserId) async {
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    await roomRef.update({
      'unreadCount.$myUserId': 0,
    });
  }"""

content = content.replace(old_mark, new_mark)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
