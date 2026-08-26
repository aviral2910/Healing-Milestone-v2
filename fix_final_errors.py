import re

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()
# factory JourneyModel.empty() should use categories: [],
content = content.replace("category: '',", "categories: [],")
with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)


with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "r") as f:
    content = f.read()
    
# Remove `widget.initialJourney!.category` which I missed
content = content.replace("_categoryController.text = widget.initialJourney!.category;", "")

with open("lib/features/journey/presentation/widgets/create_journey_overlay.dart", "w") as f:
    f.write(content)
