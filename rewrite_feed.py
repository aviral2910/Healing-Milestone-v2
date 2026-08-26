import re

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

# We want to replace:
old_start = """        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.all(20),"""

new_start = """        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Builder(
            builder: (context) {
              final bool isJourney = widget.milestone.journeyId != null && widget.milestone.journeyTitle != null;
              Widget mainCard = Container(
                padding: const EdgeInsets.all(20),"""

# But we have to close `Builder` at the bottom.
# The container ends at line 934, which is:
#             ),
#           ),
#         ),
#       ),
#     );

# Let's do a more robust string replacement by splitting the string.

parts = content.split(old_start)
if len(parts) == 2:
    prefix = parts[0]
    suffix = parts[1]
    
    # We need to find the matching closing bracket for `child: Container(`.
    # Wait, the suffix starts with `            decoration: BoxDecoration(`.
    # Since we removed `margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),` from the start, we'll put it at the very end.
    
    # Let's find the matching `)` for the Container in suffix.
    # We can just count braces.
    
    container_content = "            decoration: BoxDecoration(" + suffix
    open_count = 1 # for the Container(
    idx = 0
    while idx < len(container_content):
        if container_content[idx] == '(':
            open_count += 1
        elif container_content[idx] == ')':
            open_count -= 1
            if open_count == 0:
                break
        idx += 1
    
    if open_count == 0:
        container_body = container_content[:idx]
        rest = container_content[idx+1:] # this should be `\n          ),\n        ),\n      ),\n    );`
        
        # We construct the new child
        new_child = """Builder(
            builder: (context) {
              final bool isJourney = widget.milestone.journeyId != null && widget.milestone.journeyTitle != null;
              
              final mainCard = Container(
""" + container_body + """);

              if (!isJourney) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: mainCard,
                );
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Stack(
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
              );
            },
          )"""
          
        new_content = prefix + """        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: """ + new_child + rest
          
        with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
            f.write(new_content)
        print("Success")
    else:
        print("Failed to find matching brace")
else:
    print("Could not find the starting string")
