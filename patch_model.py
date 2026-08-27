import re

with open('lib/features/chat/data/models/chat_models.dart', 'r') as f:
    content = f.read()

old_fields = """    String? imageUrl,
    String? sharedJourneyId,
    String? sharedStoryId,
    @TimestampConverter() DateTime? createdAt,"""

new_fields = """    String? imageUrl,
    String? sharedJourneyId,
    String? sharedStoryId,
    String? sharedProfileId,
    @TimestampConverter() DateTime? createdAt,"""

content = content.replace(old_fields, new_fields)

with open('lib/features/chat/data/models/chat_models.dart', 'w') as f:
    f.write(content)
