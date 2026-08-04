import re

with open('lib/core/router/app_router.dart', 'r') as f:
    content = f.read()

# Add imports
content = content.replace("import '../../features/milestone/presentation/screens/post_creation_screen.dart';", "import '../../features/milestone/presentation/screens/post_content_screen.dart';\nimport '../../features/milestone/presentation/screens/post_settings_screen.dart';")

# Add createPostSettings to protected routes
content = content.replace("final isProtectedRoute = state.matchedLocation == AppRoutes.create ||", "final isProtectedRoute = state.matchedLocation == AppRoutes.create ||\n          state.matchedLocation == AppRoutes.createPostSettings ||")

# Replace AppRoutes.create route definition
old_route = """      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) {
          StoryModel? existingStory;
          DraftModel? draft;
          if (state.extra is StoryModel) {
            existingStory = state.extra as StoryModel;
          } else if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            if (extra.containsKey('draft')) {
              draft = extra['draft'] as DraftModel;
            }
          }
          return PostCreationScreen(existingStory: existingStory, draft: draft);
        },
      ),"""

new_route = """      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) => const PostContentScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPostSettings,
        builder: (context, state) => const PostSettingsScreen(),
      ),"""

content = content.replace(old_route, new_route)

with open('lib/core/router/app_router.dart', 'w') as f:
    f.write(content)
