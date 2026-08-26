import re

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

# Add extension for EmotionCategory
if "extension EmotionCategoryExtension on EmotionCategory" not in content:
    old_code = """enum EmotionCategory {
  positive,
  negative, // Note: Rendered as "Challenging" or "Heavy" in UI
  neutral,
}"""
    
    new_code = """import 'package:flutter/material.dart';

enum EmotionCategory {
  positive,
  negative, // Note: Rendered as "Challenging" or "Heavy" in UI
  neutral,
}

extension EmotionCategoryExtension on EmotionCategory {
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
    content = content.replace(old_code, new_code)
    
    with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
        f.write(content)
