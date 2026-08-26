import re

with open("lib/features/search/data/search_providers.dart", "r") as f:
    content = f.read()

if "import '../../../features/journey/data/models/journey_models.dart';" not in content:
    content = content.replace(
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'dart:async';\nimport '../../../features/journey/data/models/journey_models.dart';"
    )

with open("lib/features/search/data/search_providers.dart", "w") as f:
    f.write(content)
