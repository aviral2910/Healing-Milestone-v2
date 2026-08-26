import re

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

old_json = "category: json['category'] as String? ?? 'General',"
new_json = """      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
                  (json['category'] != null ? [json['category'].toString()] : []),"""

content = content.replace(old_json, new_json)

# Just in case the other one is there
content = content.replace("category: json['journey_category'] as String?,", "categories: (json['journey_categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['journey_category'] != null ? [json['journey_category'].toString()] : []),")

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)
