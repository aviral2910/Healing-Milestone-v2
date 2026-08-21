import re

with open("lib/features/journey/presentation/screens/walking_with_screen.dart", "r") as f:
    content = f.read()

# Update _WalkingWithListItem constructor
content = content.replace("class _WalkingWithListItem extends StatelessWidget {", "class _WalkingWithListItem extends StatelessWidget {\n  final bool isFollowing;")
content = content.replace("const _WalkingWithListItem({required this.journey});", "const _WalkingWithListItem({required this.journey, this.isFollowing = true});")

# Update initialIsFollowing argument
content = content.replace("initialIsFollowing: true,", "initialIsFollowing: isFollowing,")

# Update where _WalkingWithListItem is instantiated
replacement = """            itemBuilder: (context, index) {
              final isFollowing = title.toLowerCase() == 'following';
              return _WalkingWithListItem(journey: journeys[index], isFollowing: isFollowing);
            },"""
content = re.sub(r'            itemBuilder: \(context, index\) \{\n              return _WalkingWithListItem\(journey: journeys\[index\]\);\n            \},', replacement, content)

with open("lib/features/journey/presentation/screens/walking_with_screen.dart", "w") as f:
    f.write(content)

