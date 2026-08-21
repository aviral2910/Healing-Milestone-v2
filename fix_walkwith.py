import re

with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "r") as f:
    content = f.read()

# Update _WalkingWithItem constructor
content = content.replace("class _WalkingWithItem extends StatelessWidget {", "class _WalkingWithItem extends StatelessWidget {\n  final bool isFollowing;")
content = content.replace("const _WalkingWithItem({required this.journey});", "const _WalkingWithItem({required this.journey, this.isFollowing = true});")

# Update initialIsFollowing argument
content = content.replace("initialIsFollowing: true,", "initialIsFollowing: isFollowing,")

# Update where _WalkingWithItem is instantiated
# itemBuilder: (context, index) {
#   final journey = journeys[index];
#   return _WalkingWithItem(journey: journey);
# },
replacement = """                itemBuilder: (context, index) {
                  final journey = journeys[index];
                  // If the carousel title is 'Following', we assume they are following it. 
                  // Otherwise (like 'Recommended'), they are not.
                  final isFollowing = title.toLowerCase() == 'following';
                  return _WalkingWithItem(journey: journey, isFollowing: isFollowing);
                },"""
content = re.sub(r'                itemBuilder: \(context, index\) \{\n                  final journey = journeys\[index\];\n                  return _WalkingWithItem\(journey: journey\);\n                \},', replacement, content)

with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "w") as f:
    f.write(content)

