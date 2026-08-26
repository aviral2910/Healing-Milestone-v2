import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Add imports
if 'batch_media_provider.dart' not in content:
    content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", 
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:healing_milestones/features/chat/presentation/providers/batch_media_provider.dart';")

# 1. Trigger batch fetch inside data: (messages) {
trigger_code = '''data: (messages) {
                // Trigger batch fetch
                final journeyIds = messages.map((m) => m.sharedJourneyId).whereType<String>().toSet().toList();
                final storyIds = messages.map((m) => m.sharedStoryId).whereType<String>().toSet().toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (journeyIds.isNotEmpty) ref.read(batchMediaProvider.notifier).loadJourneys(journeyIds);
                  if (storyIds.isNotEmpty) ref.read(batchMediaProvider.notifier).loadStories(storyIds);
                });
'''
content = content.replace('data: (messages) {', trigger_code)

# 2. Change _MessageBubble to ConsumerWidget
content = content.replace(
    'class _MessageBubble extends StatelessWidget {',
    'class _MessageBubble extends ConsumerWidget {'
)
# ONLY replace the build method inside _MessageBubble!
content = re.sub(
    r'(class _MessageBubble extends ConsumerWidget \{[\s\S]*?@override\n  Widget build\()BuildContext context(\) \{)',
    r'\1BuildContext context, WidgetRef ref\2',
    content
)

# 3. Replace the placeholder UI
# We'll use a regex to replace both placeholders at once
placeholder_regex = r'if \(msg\.sharedJourneyId != null\)[\s\S]*?\(Batch fetch UI pending\)\'\),\n\s*\),'
new_cards = '''if (msg.sharedJourneyId != null)
              _buildSharedCard(
                context: context,
                ref: ref,
                id: msg.sharedJourneyId!,
                isJourney: true,
                isMe: isMe,
              ),
            if (msg.sharedStoryId != null)
              _buildSharedCard(
                context: context,
                ref: ref,
                id: msg.sharedStoryId!,
                isJourney: false,
                isMe: isMe,
              ),'''

content = re.sub(placeholder_regex, new_cards, content)

# 4. Add _buildSharedCard at the end of _MessageBubble
helper = '''
  Widget _buildSharedCard({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required bool isJourney,
    required bool isMe,
  }) {
    final mediaState = ref.watch(batchMediaProvider);
    final fgColor = isMe ? Colors.white : Colors.black87;
    final bgColor = isMe ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05);

    String? imageUrl;
    String? title;

    if (isJourney) {
      final journey = mediaState.journeys[id];
      if (journey == null) {
        return const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
      }
      imageUrl = journey.coverImageUrl;
      title = journey.title;
    } else {
      final story = mediaState.stories[id];
      if (story == null) {
        return const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
      }
      imageUrl = story.mainImage;
      title = story.heading;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isJourney ? Icons.map_rounded : Icons.menu_book_rounded, size: 14, color: fgColor.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(isJourney ? 'Shared Journey' : 'Shared Story', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fgColor.withValues(alpha: 0.8))),
            ],
          ),
          const SizedBox(height: 8),
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          Text(title ?? 'Untitled', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fgColor), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
'''
content = re.sub(r'\n\}\n$', helper, content)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
