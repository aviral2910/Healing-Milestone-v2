import re

with open('lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart', 'r') as f:
    content = f.read()

pattern = r"(Row\(\s*children: \[\s*AppAvatar\([\s\S]*?overflow: TextOverflow\.ellipsis,\s*\),\s*\]\,\s*\)\,\s*\)\,)"

replace = """Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (widget.visibility != MilestoneVisibility.anonymous && widget.authorId != null) {
                                      Navigator.of(context).pop();
                                      context.push(AppRoutes.publicProfile(widget.authorId!));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      AppAvatar(
                                        imageUrl: widget.authorAvatar,
                                        radius: 20,
                                        role: milestonesAsync.value?.first.authorRole,
                                        isAnonymous: widget.visibility == MilestoneVisibility.anonymous,
                                        showRing: true,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Journey by',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.8),
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    displayAuthor,
                                                    style: theme.textTheme.titleMedium
                                                        ?.copyWith(
                                                          fontWeight: FontWeight.w700,
                                                          letterSpacing: -0.3,
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isVerified) ...[
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.verified,
                                                    color: theme.colorScheme.primary,
                                                    size: 16,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (authorTitle != null &&
                                                authorTitle.isNotEmpty)
                                              Text(
                                                authorTitle,
                                                style: theme.textTheme.labelSmall
                                                    ?.copyWith(
                                                      color: theme.colorScheme.primary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),"""

# Let's replace the EXACT segment of the file.
lines = content.split('\n')
new_lines = []
skip = False
for i, line in enumerate(lines):
    if i == 234:  # 0-indexed, so line 235 is AppAvatar
        # Wait, the best way is to just replace the whole section from 234 to 297!
        pass

