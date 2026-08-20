import re

# 1. Update WalkingWithScreen
with open("lib/features/journey/presentation/screens/walking_with_screen.dart", "r") as f:
    content = f.read()

content = content.replace("const WalkingWithScreen({Key? key}) : super(key: key);",
"""final dynamic provider;
  final String title;
  
  const WalkingWithScreen({
    Key? key,
    required this.provider,
    required this.title,
  }) : super(key: key);""")

content = content.replace("final followingAsync = ref.watch(followingJourneysProvider);",
"final AsyncValue<List<JourneyModel>> followingAsync = ref.watch(provider);")

content = content.replace("title: Text(\n          'Walking With',",
"title: Text(\n          title,")

with open("lib/features/journey/presentation/screens/walking_with_screen.dart", "w") as f:
    f.write(content)


# 2. Update WalkingWithCarousel
with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "r") as f:
    carousel = f.read()

carousel = carousel.replace(
"""                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WalkingWithScreen(),
                        ),
                      );
                    },""",
"""                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WalkingWithScreen(
                            provider: provider,
                            title: title,
                          ),
                        ),
                      );
                    },""")

with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "w") as f:
    f.write(carousel)

print("Fixed View All routing")
