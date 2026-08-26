with open('firestore.rules', 'r') as f:
    content = f.read()

old_msg_rules = "allow update, delete: if isAdmin();"
new_msg_rules = "allow update, delete: if (request.auth != null && request.auth.uid == resource.data.senderId) || isAdmin();"
content = content.replace(old_msg_rules, new_msg_rules)

old_room_rules = "allow delete: if isAdmin();"
new_room_rules = "allow delete: if (request.auth != null && request.auth.uid in resource.data.participants) || isAdmin();"
content = content.replace(old_room_rules, new_room_rules)

with open('firestore.rules', 'w') as f:
    f.write(content)
