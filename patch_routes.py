import os

with open('lib/features/journey/presentation/screens/time_capsule_list_screen.dart', 'r') as f:
    content = f.read()

# Replace push route with CreateTimeCapsuleOverlay.show(context)
content = content.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\nimport 'package:healing_milestones/features/journey/presentation/widgets/create_time_capsule_overlay.dart';")
content = content.replace("onPressed: () => context.push('/create-time-capsule'),", "onPressed: () => CreateTimeCapsuleOverlay.show(context),")

with open('lib/features/journey/presentation/screens/time_capsule_list_screen.dart', 'w') as f:
    f.write(content)

