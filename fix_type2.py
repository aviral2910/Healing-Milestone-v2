with open("lib/features/journey/presentation/screens/together_feed_screen.dart", "r") as f:
    content = f.read()

if "import 'package:healing_milestones/core/models/offset_paginated_state.dart';" not in content:
    content = "import 'package:healing_milestones/core/models/offset_paginated_state.dart';\n" + content

with open("lib/features/journey/presentation/screens/together_feed_screen.dart", "w") as f:
    f.write(content)
