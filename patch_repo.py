with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

# Fix requestChat return
old_req_chat = """    if (!doc.exists) {
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
new_req_chat = """    if (!doc.exists) {
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
    return roomId;
  }"""
content = content.replace(old_req_chat, new_req_chat)

# Fix deleteChatRoom
old_del_chat = """    await batch.commit();
    return roomRef.id;
  }"""
new_del_chat = """    await batch.commit();
  }"""
content = content.replace(old_del_chat, new_del_chat)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
