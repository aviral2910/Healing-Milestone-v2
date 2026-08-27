import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_tx = """    await _firestore.runTransaction((transaction) async {
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

      // 2. Update room snippet & unread counts
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

new_tx = """    await _firestore.runTransaction((transaction) async {
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
        'createdAt': now,
        'readBy': [senderId],
      });

      // 3. WRITE room update
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? '📷 Image' : (sharedJourneyId != null ? '🔗 Shared a Journey' : '🔗 Shared a Story'));

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

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
