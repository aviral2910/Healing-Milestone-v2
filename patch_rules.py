with open('firestore.rules', 'r') as f:
    content = f.read()

content = content.replace('match /chats/{chatId}', 'match /chat_rooms/{chatId}')
content = content.replace('/documents/chats/$(chatId)', '/documents/chat_rooms/$(chatId)')

with open('firestore.rules', 'w') as f:
    f.write(content)
