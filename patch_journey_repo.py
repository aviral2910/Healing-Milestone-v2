import re

with open("lib/features/journey/data/repositories/journey_repository.dart", "r") as f:
    content = f.read()

content = content.replace("String category,", "List<String> categories,")
content = content.replace("'category': category,", "'categories': categories,")

with open("lib/features/journey/data/repositories/journey_repository.dart", "w") as f:
    f.write(content)
