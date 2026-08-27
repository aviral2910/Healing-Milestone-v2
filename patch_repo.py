import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_sig = """  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    String? text,
    File? imageFile,
    String? sharedJourneyId,
    String? sharedStoryId,
  }) async {"""

new_sig = """  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    String? text,
    File? imageFile,
    String? sharedJourneyId,
    String? sharedStoryId,
    String? sharedProfileId,
  }) async {"""

old_msg = """      // 2. WRITE message
      transaction.set(messageRef, {
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'sharedJourneyId': sharedJourneyId,
        'sharedStoryId': sharedStoryId,
        'createdAt': now,
        'readBy': [senderId],
      });"""

new_msg = """      // 2. WRITE message
      transaction.set(messageRef, {
        'senderId': senderId,
        'text': text,
        'imageUrl': imageUrl,
        'sharedJourneyId': sharedJourneyId,
        'sharedStoryId': sharedStoryId,
        'sharedProfileId': sharedProfileId,
        'createdAt': now,
        'readBy': [senderId],
      });"""

old_snippet = """      // 3. WRITE room update
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? '📷 Image' : (sharedJourneyId != null ? '🔗 Shared a Journey' : '🔗 Shared a Story'));"""

new_snippet = """      // 3. WRITE room update
      final snippet = text?.isNotEmpty == true 
          ? text 
          : (imageUrl != null ? '📷 Image' : (sharedJourneyId != null ? '🔗 Shared a Journey' : (sharedStoryId != null ? '🔗 Shared a Post' : '👤 Shared a Profile')));"""

content = content.replace(old_sig, new_sig)
content = content.replace(old_msg, new_msg)
content = content.replace(old_snippet, new_snippet)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
