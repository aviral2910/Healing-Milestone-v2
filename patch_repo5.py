import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_snippet = """      // 3. WRITE room update
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? '📷 Image' : (sharedJourneyId != null ? '🔗 Shared a Journey' : (sharedStoryId != null ? '🔗 Shared a Post' : '👤 Shared a Profile')));"""

new_snippet = """      // 3. WRITE room update
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? (isViewOnce ? '⏱️ View Once Photo' : '📷 Image') : (sharedJourneyId != null ? '🔗 Shared a Journey' : (sharedStoryId != null ? '🔗 Shared a Post' : '👤 Shared a Profile')));"""

content = content.replace(old_snippet, new_snippet)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
