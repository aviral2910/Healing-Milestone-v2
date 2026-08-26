with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_sent = """  Stream<List<ChatRoom>> watchSentRequests(String myUserId) {
    return _firestore
        .collection('chat_rooms')
        .where('initiatorId', isEqualTo: myUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }"""
new_sent = """  Stream<List<ChatRoom>> watchSentRequests(String myUserId) {
    return _firestore
        .collection('chat_rooms')
        .where('initiatorId', isEqualTo: myUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).where((r) => r.status == 'pending').toList());
  }"""
content = content.replace(old_sent, new_sent)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
