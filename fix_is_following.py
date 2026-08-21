import re

# Fix carousel
with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "r") as f:
    content = f.read()

replacement1 = """                itemBuilder: (context, index) {
                  final journey = journeys[index];
                  return _WalkingWithItem(journey: journey, isFollowing: journey.isFollowing);
                },"""
content = re.sub(r'                itemBuilder: \(context, index\) \{\n                  final journey = journeys\[index\];\n                  // If the carousel title is \'Following\', we assume they are following it\. \n                  // Otherwise \(like \'Recommended\'\), they are not\.\n                  final isFollowing = title\.toLowerCase\(\) == \'following\';\n                  return _WalkingWithItem\(journey: journey, isFollowing: isFollowing\);\n                \},', replacement1, content)
with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "w") as f:
    f.write(content)


# Fix screen
with open("lib/features/journey/presentation/screens/walking_with_screen.dart", "r") as f:
    content2 = f.read()
replacement2 = """            itemBuilder: (context, index) {
              return _WalkingWithListItem(journey: journeys[index], isFollowing: journeys[index].isFollowing);
            },"""
content2 = re.sub(r'            itemBuilder: \(context, index\) \{\n              final isFollowing = title\.toLowerCase\(\) == \'following\';\n              return _WalkingWithListItem\(journey: journeys\[index\], isFollowing: isFollowing\);\n            \},', replacement2, content2)

with open("lib/features/journey/presentation/screens/walking_with_screen.dart", "w") as f:
    f.write(content2)

