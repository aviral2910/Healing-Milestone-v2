import re

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'r') as f:
    content = f.read()

# Update loadJourneys catch block
old_catch_j = """    } catch (e) {
      print('Error loadJourneys: $e');
      // If we remove them, they get retried endlessly by the UI!
      // Let's NOT remove them from _requestedJourneys so it stops spinning/retrying.
    }"""
new_catch_j = """    } catch (e) {
      print('Error loadJourneys: $e');
      // Update state with nulls to stop infinite loading shimmer
      final errorJourneys = <String, JourneyModel?>{
        for (var id in needed) id: null
      };
      if (mounted) {
        state = state.copyWith(journeys: {...state.journeys, ...errorJourneys});
      }
    }"""
content = content.replace(old_catch_j, new_catch_j)

# Update loadStories catch block
old_catch_s = """    } catch (e) {
      print('Error loadStories: $e');
      // Do not remove to prevent infinite reload loop if server is failing
    }"""
new_catch_s = """    } catch (e) {
      print('Error loadStories: $e');
      final errorStories = <String, StoryModel?>{
        for (var id in needed) id: null
      };
      if (mounted) {
        state = state.copyWith(stories: {...state.stories, ...errorStories});
      }
    }"""
content = content.replace(old_catch_s, new_catch_s)

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'w') as f:
    f.write(content)
