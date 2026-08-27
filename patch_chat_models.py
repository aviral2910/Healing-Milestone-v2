import re

with open('lib/features/chat/data/models/chat_models.dart', 'r') as f:
    content = f.read()

old_code = """    @TimestampConverter() DateTime? createdAt,
    @Default([]) List<String> readBy,
  }) = _ChatMessage;"""

new_code = """    @TimestampConverter() DateTime? createdAt,
    @Default([]) List<String> readBy,
    @Default(false) bool isViewOnce,
    @Default(false) bool isViewed,
  }) = _ChatMessage;"""

content = content.replace(old_code, new_code)

with open('lib/features/chat/data/models/chat_models.dart', 'w') as f:
    f.write(content)
