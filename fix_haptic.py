import re

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "r") as f:
    content = f.read()

# Add import if missing
if "package:flutter/services.dart" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';")

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "w") as f:
    f.write(content)
