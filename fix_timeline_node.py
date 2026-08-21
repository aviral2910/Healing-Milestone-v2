import re

with open("lib/features/journey/presentation/widgets/timeline_node.dart", "r") as f:
    content = f.read()

replacement = """                            ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!));
                            ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!, isPublic: true));"""

content = content.replace("                            ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!));", replacement)

replacement2 = """                          ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!));
                          ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!, isPublic: true));"""
content = content.replace("                          ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!));", replacement2)

replacement3 = """                                  ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!));
                                  ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!, isPublic: true));"""
content = content.replace("                                  ref.invalidate(paginatedJourneyMilestonesProvider(milestone.journeyId!));", replacement3)


with open("lib/features/journey/presentation/widgets/timeline_node.dart", "w") as f:
    f.write(content)
