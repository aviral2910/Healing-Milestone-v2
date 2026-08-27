import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_update = """      transaction.update(roomRef, {
        'lastMessageText': snippet,
        'lastMessageTime': now,
      });"""

new_update = """      transaction.update(roomRef, {
        'lastMessageText': snippet,
        'lastMessageSenderId': senderId,
        'lastMessageTime': now,
      });"""

content = content.replace(old_update, new_update)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
