import re

with open('lib/features/chat/data/chat_repository.dart', 'r') as f:
    content = f.read()

old_code = """  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    String? text,
    File? imageFile,
    String? sharedJourneyId,
    String? sharedStoryId,
    String? sharedProfileId,
  }) async {"""

new_code = """  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    String? text,
    File? imageFile,
    String? sharedJourneyId,
    String? sharedStoryId,
    String? sharedProfileId,
    bool isViewOnce = false,
  }) async {"""

content = content.replace(old_code, new_code)

old_doc = """      'sharedJourneyId': sharedJourneyId,
      'sharedStoryId': sharedStoryId,
      'sharedProfileId': sharedProfileId,
    });"""

new_doc = """      'sharedJourneyId': sharedJourneyId,
      'sharedStoryId': sharedStoryId,
      'sharedProfileId': sharedProfileId,
      'isViewOnce': isViewOnce,
      'isViewed': false,
    });"""

content = content.replace(old_doc, new_doc)

with open('lib/features/chat/data/chat_repository.dart', 'w') as f:
    f.write(content)
