import re

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'r') as f:
    content = f.read()

# Change Map signatures to allow nullable values
content = content.replace("final Map<String, JourneyModel> journeys;", "final Map<String, JourneyModel?> journeys;")
content = content.replace("final Map<String, StoryModel> stories;", "final Map<String, StoryModel?> stories;")

content = content.replace("Map<String, JourneyModel>? journeys,", "Map<String, JourneyModel?>? journeys,")
content = content.replace("Map<String, StoryModel>? stories,", "Map<String, StoryModel?>? stories,")

# Update loadJourneys to insert nulls for missing IDs
old_load_j = """        // Also populate nulls for missing IDs so they stop loading
        for (var id in needed) {
          if (!newJourneys.containsKey(id)) {
            // we can't insert null into a Map<String, JourneyModel> unless we make it JourneyModel?
            // Wait, if it's missing, it'll just stay loading. But we don't want it to load forever.
          }
        }"""
new_load_j = """        for (var id in needed) {
          if (!newJourneys.containsKey(id)) {
            newJourneys[id] = null;
          }
        }"""
content = content.replace(old_load_j, new_load_j)

# Update loadStories to insert nulls
old_load_s = """      final newStories = {
        for (var s in data)
          s['id'].toString(): StoryModel.fromMap(s, s['id'].toString()),
      };
      if (mounted) {
        state = state.copyWith(stories: {...state.stories, ...newStories});
      }
    } catch (e) {
      print('Error loadStories: $e');
      _requestedStories.removeAll(needed); // Allow retry
    }"""
new_load_s = """      final newStories = <String, StoryModel?>{
        for (var s in data)
          s['id'].toString(): StoryModel.fromMap(s, s['id'].toString()),
      };
      
      for (var id in needed) {
        if (!newStories.containsKey(id)) {
          newStories[id] = null;
        }
      }
      
      if (mounted) {
        state = state.copyWith(stories: {...state.stories, ...newStories});
      }
    } catch (e) {
      print('Error loadStories: $e');
      // Do not remove to prevent infinite reload loop if server is failing
    }"""
content = content.replace(old_load_s, new_load_s)

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'w') as f:
    f.write(content)
