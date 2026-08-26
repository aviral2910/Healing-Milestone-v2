import re

# 1. Shrink tags in journey_detail_screen.dart
with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

# Remove categories from FlexibleSpaceBar.title
old_title_content = """                  if (widget.categories != null && widget.categories!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: widget.categories!.map((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
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
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                                )).toList(),
                              ),
                            ),
                          ],"""

content = content.replace(old_title_content, "")

# Instead of putting them in SliverAppBar.bottom which pins them, let's put them in a SliverToBoxAdapter right below the SliverAppBar!
# Wait, let's see where SliverAppBar ends.
# It ends with:
#               ),
#             ),
#           ),
#           // Then we have SliverList or SliverPadding

# We can insert a SliverToBoxAdapter before the next sliver.
# Let's search for "SliverPadding(" or similar after "SliverAppBar("
sliver_app_bar_end_pattern = r"            \),\n          \),\n          // (?:milestones|Loading|Empty)"

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

# Finding the exact spot to inject:
# We know CustomScrollView -> slivers: [ SliverAppBar( ... ), <inject here> 
# Let's find "SliverPadding(" or "SliverList(" after SliverAppBar.

idx = content.find("SliverAppBar(")
if idx != -1:
    # search for the next Sliver inside slivers array
    idx_next_sliver = content.find("          SliverPadding(", idx)
    if idx_next_sliver == -1:
        idx_next_sliver = content.find("          SliverToBoxAdapter(", idx)
    if idx_next_sliver == -1:
        idx_next_sliver = content.find("          SliverList(", idx)
    
    if idx_next_sliver != -1:
        content = content[:idx_next_sliver] + sliver_tags_injection + content[idx_next_sliver:]

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)

# 2. Shrink tags in public_journey_detail_overlay.dart
with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "r") as f:
    content = f.read()

content = content.replace("""padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),""", """padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),""")
content = content.replace("""fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,""", """fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    fontSize: 9,""")
content = content.replace("borderRadius: BorderRadius.circular(8)", "borderRadius: BorderRadius.circular(6)")

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "w") as f:
    f.write(content)

