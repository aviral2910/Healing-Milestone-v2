import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_delete_msg = """  Future<void> deleteMessage(String roomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }"""

new_delete_msg = """  Future<void> deleteMessage(String roomId, String messageId) async {
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
  }"""
content = content.replace(old_delete_msg, new_delete_msg)

old_delete_room = """  Future<void> deleteChatRoom(String roomId) async {
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
  }"""

new_delete_room = """  Future<void> deleteChatRoom(String roomId) async {
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
  }"""
content = content.replace(old_delete_room, new_delete_room)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
