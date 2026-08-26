with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

new_methods = """  Future<void> deleteMessage(String roomId, String messageId) async {
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
"""

# Insert before the last brace
content = content.rsplit('}', 1)[0] + new_methods + '}\n'

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
