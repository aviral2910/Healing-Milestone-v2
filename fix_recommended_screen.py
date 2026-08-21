import re

with open("lib/features/posts/presentation/screens/recommended_swipe_screen.dart", "r") as f:
    content = f.read()

replacement = """            if (storiesAsync.isLoading)
              const ServerHealingLoader(isSliver: true)"""

content = re.sub(r'            if \(storiesAsync\.isLoading\)\n              const SliverFillRemaining\(\n                child: Center\(\n                  child: const AppLoader\.small\(\),\n                \),\n              \)', replacement, content)

with open("lib/features/posts/presentation/screens/recommended_swipe_screen.dart", "w") as f:
    f.write(content)
