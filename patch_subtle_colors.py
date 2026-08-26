import re

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

old_code = """extension EmotionCategoryExtension on EmotionCategory {
  Color get color {
    switch (this) {
      case EmotionCategory.positive:
        return Colors.green;
      case EmotionCategory.negative:
        return Colors.purple;
      case EmotionCategory.neutral:
        return Colors.grey;
    }
  }
}"""

new_code = """extension EmotionCategoryExtension on EmotionCategory {
  Color get color {
    switch (this) {
      case EmotionCategory.positive:
        return const Color(0xFF5FA072); // Subtle Sage Green
      case EmotionCategory.negative:
        return const Color(0xFF9B7EBD); // Subtle Muted Purple
      case EmotionCategory.neutral:
        return const Color(0xFF9CA3AF); // Subtle Cool Grey
    }
  }
}"""

content = content.replace(old_code, new_code)

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)
