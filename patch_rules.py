import re

with open('firestore.rules', 'r') as f:
    content = f.read()

old_rule = """        allow update, delete: if (request.auth != null && request.auth.uid == resource.data.senderId) || isAdmin();"""

new_rule = """        allow update: if (request.auth != null && request.auth.uid == resource.data.senderId) || isAdmin();
        allow delete: if request.auth != null && (request.auth.uid == resource.data.senderId || request.auth.uid in get(/databases/$(database)/documents/chat_rooms/$(chatId)).data.participants || isAdmin());"""

content = content.replace(old_rule, new_rule)

with open('firestore.rules', 'w') as f:
    f.write(content)
