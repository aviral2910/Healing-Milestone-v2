import re

with open('lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart', 'r') as f:
    content = f.read()

pattern = r"(Row\(\s*children: \[\s*AppAvatar\()"
replace = """GestureDetector(
                            onTap: () {
                              if (widget.visibility != MilestoneVisibility.anonymous && widget.authorId != null) {
                                Navigator.of(context).pop();
                                context.push(AppRoutes.publicProfile(widget.authorId!));
                              }
                            },
                            child: \\1"""

content = re.sub(pattern, replace, content)

# Also close the GestureDetector wrapper
pattern2 = r"(\s*\]\,\s*\)\,\s*\)\,\s*\]\,\s*\)\,\s*)(const SizedBox\(height: 16\),)"
replace2 = r"\1),\n                          \2"

# Wait, let me do this manually with a direct replace
