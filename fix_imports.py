with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

content = content.replace("import 'package:flutter/material.dart';\n\nenum EmotionCategory", "enum EmotionCategory")
content = "import 'package:flutter/material.dart';\n" + content

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)
