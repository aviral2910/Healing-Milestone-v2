import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_builder = """                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (journeyIds.isNotEmpty)
                    ref
                        .read(batchMediaProvider.notifier)
                        .loadJourneys(journeyIds);
                  if (storyIds.isNotEmpty)
                    ref.read(batchMediaProvider.notifier).loadStories(storyIds);
                });"""

new_builder = """                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (journeyIds.isNotEmpty)
                    ref
                        .read(batchMediaProvider.notifier)
                        .loadJourneys(journeyIds);
                  if (storyIds.isNotEmpty)
                    ref.read(batchMediaProvider.notifier).loadStories(storyIds);
                    
                  // Mark chat as read
                  if (currentUser?.userId != null) {
                    ref.read(chatRepositoryProvider).markAsRead(widget.roomId, currentUser!.userId!);
                  }
                });"""

content = content.replace(old_builder, new_builder)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
