import re

with open('lib/features/chat/data/models/chat_models.dart', 'r') as f:
    content = f.read()

old_fields = """    required String initiatorId,
    @Default("") String lastMessageText,
    @TimestampConverter() DateTime? lastMessageTime,"""

new_fields = """    required String initiatorId,
    @Default("") String lastMessageText,
    @Default("") String lastMessageSenderId,
    @TimestampConverter() DateTime? lastMessageTime,"""

content = content.replace(old_fields, new_fields)

with open('lib/features/chat/data/models/chat_models.dart', 'w') as f:
    f.write(content)
