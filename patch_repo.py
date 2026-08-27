import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

ext_code = """extension ChatRepositoryViewOnce on ChatRepository {
  Future<void> markMessageAsViewed(String roomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'isViewed': true});
  }
}
"""

content = content.replace(ext_code, "")

new_method = """  Future<void> markMessageAsViewed(String roomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'isViewed': true});
  }
"""

content = content.replace("  Future<void> markAsRead(String roomId, String userId) async {", new_method + "\n  Future<void> markAsRead(String roomId, String userId) async {")

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
