with open("lib/features/journey/presentation/screens/my_path_screen.dart", "r") as f:
    content = f.read()

content = content.replace(
    "ref.invalidate(\n                                                    recommendedMilestonesProvider, followingMilestonesProvider,\n                                                  );",
    "ref.invalidate(recommendedMilestonesProvider);\n                                                  ref.invalidate(followingMilestonesProvider);"
)

with open("lib/features/journey/presentation/screens/my_path_screen.dart", "w") as f:
    f.write(content)
