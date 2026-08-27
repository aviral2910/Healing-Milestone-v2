import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_mark = """  Future<void> markMessageAsViewed(String roomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'isViewed': true});
  }"""

new_mark = """  Future<void> markMessageAsViewed(String roomId, String messageId) async {
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
  }"""
content = content.replace(old_mark, new_mark)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
