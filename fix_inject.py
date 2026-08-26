with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

sliver_tags_injection = """
          if (widget.categories != null && widget.categories!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: widget.categories!.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#${cat.toUpperCase()}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),
"""

# Insert right before "          Consumer("
idx = content.find("          Consumer(\n            builder: (context, ref, child) {")
if idx != -1:
    content = content[:idx] + sliver_tags_injection + content[idx:]
else:
    print("Failed to find Consumer")

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)
