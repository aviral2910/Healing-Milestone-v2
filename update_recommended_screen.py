import re

with open("lib/features/posts/presentation/screens/recommended_swipe_screen.dart", "r") as f:
    content = f.read()

if "import '../../../../shared/widgets/server_healing_loader.dart';" not in content:
    content = content.replace("import '../../../../shared/widgets/app_loader.dart';", "import '../../../../shared/widgets/app_loader.dart';\nimport '../../../../shared/widgets/server_healing_loader.dart';")

replacement = """      if (filteredStories.isEmpty && !paginatedResponse.isEnd)
        const ServerHealingLoader(isSliver: true)"""

content = re.sub(r'      if \(filteredStories\.isEmpty && !paginatedResponse\.isEnd\)\n        const SliverFillRemaining\(\n          hasScrollBody: false,\n          child: Padding\(\n            padding: EdgeInsets\.all\(32\.0\),\n            child: Center\(\n              child: const AppLoader\.small\(\),\n            \),\n          \),\n        \)', replacement, content)

with open("lib/features/posts/presentation/screens/recommended_swipe_screen.dart", "w") as f:
    f.write(content)
