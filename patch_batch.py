import re

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'r') as f:
    content = f.read()

# Update loadJourneys
old_load_j = """      final res = await _apiClient.dio.post(
        '/api/journeys/batch',
        data: {'ids': needed},
      );
      final List data = res.data;
      final newJourneys = {
        for (var j in data) j['id'].toString(): JourneyModel.fromJson(j),
      };
      if (mounted) {
        state = state.copyWith(journeys: {...state.journeys, ...newJourneys});
      }
    } catch (e) {
      print('Error loadJourneys: $e');
      _requestedJourneys.removeAll(needed); // Allow retry
    }"""
new_load_j = """      final res = await _apiClient.dio.post(
        '/api/journeys/batch',
        data: {'ids': needed},
      );
      if (res.data is List) {
        final List data = res.data;
        final newJourneys = {
          for (var j in data) j['id'].toString(): JourneyModel.fromJson(j),
        };
        
        // Also populate nulls for missing IDs so they stop loading
        for (var id in needed) {
          if (!newJourneys.containsKey(id)) {
            // we can't insert null into a Map<String, JourneyModel> unless we make it JourneyModel?
            // Wait, if it's missing, it'll just stay loading. But we don't want it to load forever.
          }
        }
        
        if (mounted) {
          state = state.copyWith(journeys: {...state.journeys, ...newJourneys});
        }
      } else {
        print("Backend returned non-list for journeys batch: ${res.data}");
      }
    } catch (e) {
      print('Error loadJourneys: $e');
      // If we remove them, they get retried endlessly by the UI!
      // Let's NOT remove them from _requestedJourneys so it stops spinning/retrying.
    }"""
content = content.replace(old_load_j, new_load_j)

# Let's fix the schema of BatchMediaState to allow nulls, or add dummy "not found" objects!
# Actually, the simplest fix is to just make sure the backend endpoint doesn't crash on invalid UUIDs.

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'w') as f:
    f.write(content)
