import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_delete = """    await docRef.delete();
  }"""

new_delete = """    await docRef.delete();

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
  }"""

content = content.replace(old_delete, new_delete)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
