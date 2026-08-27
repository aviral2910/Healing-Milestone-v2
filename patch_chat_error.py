import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# _buildSharedCard
old_journey = """    if (isJourney) {
      final journey = mediaState.journeys[id];
      if (journey == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 80, radius: 12),
        );
      }
      imageUrl = null;
      title = journey.title;
    } else {"""
new_journey = """    if (isJourney) {
      if (!mediaState.journeys.containsKey(id)) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 80, radius: 12),
        );
      }
      final journey = mediaState.journeys[id];
      if (journey == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Journey unavailable', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        );
      }
      imageUrl = null;
      title = journey.title;
    } else {"""
content = content.replace(old_journey, new_journey)


old_story = """    } else {
      final story = mediaState.stories[id];
      if (story == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 160, radius: 12),
        );
      }
      imageUrl = story.mainImage;
      title = story.heading;
    }"""
new_story = """    } else {
      if (!mediaState.stories.containsKey(id)) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 160, radius: 12),
        );
      }
      final story = mediaState.stories[id];
      if (story == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Post unavailable', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        );
      }
      imageUrl = story.mainImage;
      title = story.heading;
    }"""
content = content.replace(old_story, new_story)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
