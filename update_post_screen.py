import re

with open("lib/features/posts/presentation/screens/post_screen.dart", "r") as f:
    content = f.read()

if "import '../../../../shared/widgets/server_healing_loader.dart';" not in content:
    content = content.replace("import '../../../../shared/widgets/app_loader.dart';", "import '../../../../shared/widgets/app_loader.dart';\nimport '../../../../shared/widgets/server_healing_loader.dart';")

replacement = "loading: () => const ServerHealingLoader(isSliver: true),"

content = re.sub(r'loading: \(\) => const SliverFillRemaining\(\s*child: Center\(child: const AppLoader\.small\(\)\),\s*\),', replacement, content)

with open("lib/features/posts/presentation/screens/post_screen.dart", "w") as f:
    f.write(content)
