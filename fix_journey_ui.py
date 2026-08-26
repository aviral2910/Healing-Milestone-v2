import re

files_to_fix = [
    "lib/features/journey/data/models/journey_models.dart",
    "lib/features/journey/presentation/screens/my_path_screen.dart",
    "lib/features/journey/presentation/screens/public_user_journeys_screen.dart",
    "lib/features/journey/presentation/screens/walking_with_screen.dart",
    "lib/features/journey/presentation/widgets/public_journey_carousel.dart",
    "lib/features/journey/presentation/widgets/walking_with_carousel.dart"
]

for filepath in files_to_fix:
    with open(filepath, "r") as f:
        content = f.read()

    if "journey_models.dart" in filepath:
        content = content.replace("category: '',", "categories: [],")
    else:
        # For navigations passing category
        content = content.replace("category: journey.category,", "category: journey.categories.isNotEmpty ? journey.categories.first : 'General',")
        
        # For displaying category text
        # Usually it's journey.category.toUpperCase()
        content = content.replace("journey.category.toUpperCase()", "(journey.categories.isNotEmpty ? journey.categories.join(' • ') : 'GENERAL').toUpperCase()")
        
        # Or just journey.category
        content = content.replace("journey.category,", "(journey.categories.isNotEmpty ? journey.categories.first : 'General'),")

    with open(filepath, "w") as f:
        f.write(content)

