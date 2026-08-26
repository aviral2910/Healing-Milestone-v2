with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

old_stack = """              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom-most page
                    Positioned(
                      top: 12,
                      bottom: -12,
                      left: 12,
                      right: -12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                    // Middle page
                    Positioned(
                      top: 6,
                      bottom: -6,
                      left: 6,
                      right: -6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                    // Top page (actual card)
                    mainCard,
                  ],
                ),
              );"""

new_stack = """              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom-most page
                    Positioned(
                      top: 12,
                      bottom: -12,
                      left: 12,
                      right: -12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                    // Middle page
                    Positioned(
                      top: 6,
                      bottom: -6,
                      left: 6,
                      right: -6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                    // Top page (actual card)
                    mainCard,
                  ],
                ),
              );"""

content = content.replace(old_stack, new_stack)

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
    f.write(content)
