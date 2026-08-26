import re

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

content = content.replace("final String? journeyCategory;", "final List<String>? journeyCategories;")
content = content.replace("this.journeyCategory,", "this.journeyCategories,")
content = content.replace("journeyCategory: json['journey_category'] as String?,", "journeyCategories: (json['journey_categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['journey_category'] != null ? [json['journey_category'].toString()] : null),")
content = content.replace("String? journeyCategory,", "List<String>? journeyCategories,")
content = content.replace("journeyCategory: journeyCategory ?? this.journeyCategory,", "journeyCategories: journeyCategories ?? this.journeyCategories,")

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)

# Fix where it was used
import os
for root, _, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, "r") as f:
                c = f.read()
            if "journeyCategory" in c:
                # Replace journeyCategory with journeyCategories?.first
                # Mostly in together_feed_card.dart or timeline_node.dart
                c = c.replace("journeyCategory: ", "journeyCategories: ")
                c = c.replace("milestone.journeyCategory", "(milestone.journeyCategories?.isNotEmpty == true ? milestone.journeyCategories!.first : null)")
                with open(filepath, "w") as f:
                    f.write(c)

