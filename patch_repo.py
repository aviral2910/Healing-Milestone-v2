with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_watch = """        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).where((r) => r.status == 'accepted').toList());"""

new_watch = """        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).where((r) => r.status == 'accepted' || (r.status == 'pending' && r.initiatorId == myUserId)).toList());"""

content = content.replace(old_watch, new_watch)
with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
