import sys

with open('lib/core/router/app_router.dart', 'r') as f:
    content = f.read()

# Remove import
content = content.replace("import '../../features/journey/presentation/screens/create_time_capsule_screen.dart';", "")

# Remove route definition
route_def = """      GoRoute(
        path: '/create-time-capsule',
        builder: (context, state) => const CreateTimeCapsuleScreen(),
      ),"""

if route_def in content:
    content = content.replace(route_def, "")
else:
    # Try alternate formatting
    print("Could not find exact route def to remove")

with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(content)
