with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

old_block = """        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.all(20),"""

new_block = """        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Builder(
            builder: (context) {
              final bool isJourney = widget.milestone.journeyId != null && widget.milestone.journeyTitle != null;
              
              final mainCard = Container(
                padding: const EdgeInsets.all(20),"""

parts = content.split(old_block)
if len(parts) == 2:
    prefix = parts[0]
    suffix = parts[1]
    
    # suffix starts with `\n            decoration: BoxDecoration(`
    # We need to find the matching closing bracket for `Container(`.
    # Since we replaced `child: Container(`, the matching closing brace is at the end.
    
    container_content = suffix
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
        rest = container_content[idx+1:]
        
        new_child = new_block + container_body + """);

              if (!isJourney) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: mainCard,
                );
              }

              return Container(
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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
          
        new_content = prefix + new_child + rest
        
        with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
            f.write(new_content)
        print("Success")
    else:
        print("Failed to find matching brace")
else:
    print("Could not find the starting string")
