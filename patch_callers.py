import re

# 1. journey_detail_screen.dart
with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

# showJourneyShareOptions(context, widget.journeyId, widget.title); -> showJourneyShareOptions(context, widget.journeyId, widget.title, isMine: widget.isMine);
content = content.replace("showJourneyShareOptions(context, widget.journeyId, widget.title);", "showJourneyShareOptions(context, widget.journeyId, widget.title, isMine: widget.isMine);")

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)

# 2. public_journey_detail_overlay.dart
with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "r") as f:
    content = f.read()

old_call = """                              showJourneyShareOptions(
                                context,
                                widget.journeyId,
                                widget.title,
                              );"""
new_call = """                              showJourneyShareOptions(
                                context,
                                widget.journeyId,
                                widget.title,
                                isMine: widget.isMine,
                                authorName: displayAuthor,
                              );"""
content = content.replace(old_call, new_call)

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "w") as f:
    f.write(content)
