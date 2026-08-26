import re

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

content = content.replace("widget.(milestone.journeyCategories?.isNotEmpty == true ? milestone.journeyCategories!.first : null)", "(widget.milestone.journeyCategories?.isNotEmpty == true ? widget.milestone.journeyCategories!.first : null)")

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
    f.write(content)

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

content = content.replace("'journey_category': journeyCategory,", "'journey_categories': journeyCategories,")

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)

