with open("lib/features/chat/data/models/chat_models.dart", "r") as f:
    content = f.read()

content = content.replace(
    "class ChatRoom with _$ChatRoom {",
    "class ChatRoom with _$ChatRoom {\n  const ChatRoom._();"
)

content = content.replace(
    "class ChatMessage with _$ChatMessage {",
    "class ChatMessage with _$ChatMessage {\n  const ChatMessage._();"
)

with open("lib/features/chat/data/models/chat_models.dart", "w") as f:
    f.write(content)
