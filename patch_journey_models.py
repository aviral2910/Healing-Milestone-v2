import re

with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

# Replace category string with categories list
content = content.replace("final String category;", "final List<String> categories;")

# In constructor
content = content.replace("required this.category,", "required this.categories,")
content = content.replace("this.category = '',", "this.categories = const [],")

# In copyWith
content = content.replace("String? category,", "List<String>? categories,")
content = content.replace("category: category ?? this.category,", "categories: categories ?? this.categories,")

# In fromJson
# Be careful here, some might have old string categories if they are cached, let's gracefully handle it
from_json_replacement = """      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
                  (json['category'] != null ? [json['category'].toString()] : []),"""
content = content.replace("category: json['category'] ?? '',", from_json_replacement)

# In toJson
content = content.replace("'category': category,", "'categories': categories,")

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)
