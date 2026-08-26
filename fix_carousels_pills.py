import re

pill_ui = """SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: (journey.categories.isNotEmpty ? journey.categories : ['General']).map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Text(
                      '#${cat.toUpperCase()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontSize: 8,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            )"""

def replace_in_carousel(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # Find the Category row
    # Row(
    #   children: [
    #     Icon(
    #       Icons.folder_rounded, ...
    
    old_row_regex = r"Row\(\s*children:\s*\[\s*Icon\(\s*Icons\.folder_rounded,[\s\S]*?\),[\s\S]*?\],\s*\)"
    content = re.sub(old_row_regex, pill_ui, content)

    with open(filepath, "w") as f:
        f.write(content)

replace_in_carousel("lib/features/journey/presentation/widgets/public_journey_carousel.dart")
replace_in_carousel("lib/features/journey/presentation/widgets/walking_with_carousel.dart")

# For together_feed_card.dart, it uses a slightly different format
def replace_in_together(filepath):
    with open(filepath, "r") as f:
        content = f.read()
    
    # It has:
    # Text(
    #   '#${(widget.journey.categories.isNotEmpty ? widget.journey.categories.join(' • ') : 'GENERAL').toUpperCase()}',
    #   ...
    # )
    # Let's just find that text
    
    old_text_regex = r"Text\(\s*'#\$\{\(widget\.journey\.categories\.isNotEmpty \? widget\.journey\.categories\.join\(' • '\) : 'GENERAL'\)\.toUpperCase\(\)\}',[\s\S]*?\),"
    
    new_pill_ui = """SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: (widget.journey.categories.isNotEmpty ? widget.journey.categories : ['General']).map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1),
                                      ),
                                      child: Text(
                                        '#${cat.toUpperCase()}',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ),"""
    
    content = re.sub(old_text_regex, new_pill_ui, content)
    with open(filepath, "w") as f:
        f.write(content)

replace_in_together("lib/features/journey/presentation/widgets/together_feed_card.dart")

