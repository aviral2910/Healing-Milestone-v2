import re

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'r') as f:
    content = f.read()

old_journeys = """        final newJourneys = {
          for (var j in data) j['id'].toString(): JourneyModel.fromJson(j),
        };"""
new_journeys = """        final newJourneys = <String, JourneyModel?>{
          for (var j in data) j['id'].toString(): JourneyModel.fromJson(j),
        };"""
content = content.replace(old_journeys, new_journeys)

with open('lib/features/chat/presentation/providers/batch_media_provider.dart', 'w') as f:
    f.write(content)
