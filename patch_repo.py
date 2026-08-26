with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_request = """  Future<void> requestChat(String targetUserId) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) throw Exception('Not authenticated');

    final uids = [myUid, targetUserId]..sort();
    final roomId = 'chat_${uids[0]}_${uids[1]}';

    final docRef = _firestore.collection('chat_rooms').doc(roomId);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      // Check mutual following to set status directly to 'accepted' if mutual
      bool isMutual = false;
      try {
        final myFollowsDoc = await _firestore.collection('users').doc(myUid).collection('following').doc(targetUserId).get();
        final targetFollowsDoc = await _firestore.collection('users').doc(targetUserId).collection('following').doc(myUid).get();
        if (myFollowsDoc.exists && targetFollowsDoc.exists) {
          isMutual = true;
        }
      } catch (e) {
        // Fallback to pending if we don't have read access to target's following list
      }

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
  }"""

new_request = """  Future<void> requestChat(String targetUserId, {bool isMutual = false}) async {
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
  }"""

content = content.replace(old_request, new_request)
with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
