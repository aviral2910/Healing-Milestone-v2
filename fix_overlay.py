import re

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "r") as f:
    content = f.read()

replacement = """      // Optionally refresh the feed
      ref.invalidate(recommendedMilestonesProvider);
      ref.invalidate(followingMilestonesProvider);
      ref.invalidate(recommendedJourneysProvider);
      ref.invalidate(followingJourneysProvider);"""
content = content.replace("""      // Optionally refresh the feed
      ref.invalidate(recommendedMilestonesProvider);
      ref.invalidate(followingMilestonesProvider);""", replacement)

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "w") as f:
    f.write(content)
