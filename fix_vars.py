with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

# Just blind replace title and category in the build method, wait, they only appear there anyway.
# We can just replace the specific lines.
# Line 228 probably: "title," or similar
content = content.replace("title,\n                            style: theme.textTheme.headlineMedium?", "widget.title,\n                            style: theme.textTheme.headlineMedium?")
content = content.replace("Text(category,", "Text(widget.category,")

# Any other occurrences?
import re
content = re.sub(r'\b(title)\b', 'widget.title', content)
content = re.sub(r'\b(category)\b', 'widget.category', content)
# Now fix the constructor and fields!
content = content.replace("final String widget.title;", "final String title;")
content = content.replace("final String? widget.category;", "final String? category;")
content = content.replace("this.widget.title", "this.title")
content = content.replace("this.widget.category", "this.category")
content = content.replace("required this.widget.title", "required this.title")
content = content.replace("required this.widget.category", "required this.category")
content = content.replace("widget.widget.", "widget.")

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)
