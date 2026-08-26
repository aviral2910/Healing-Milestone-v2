import re

def fix_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # We need to replace the entire if (widget.category != null) ... block
    # It starts with "if (widget.category != null) ...["
    # and ends with "]," some lines down.
    
    # We use a regex that handles this:
    pattern = r"if \(widget\.category != null\) \.\.\.\[[\s\S]*?\]"
    # Actually wait, there could be multiple `]` brackets inside.
    # Let's find "if (widget.category != null) ...[" and replace up to the matching "]" 
    # but it's simpler to just do string matching.
    
    # Wait, in Python I can use re.sub with non-greedy up to a known text after the block.
    # Let's find the text after the block. 
    # In public_journey_detail_overlay, what's after?
    return content

# I will just write Python to correctly find the matching brackets.

def find_matching_bracket(text, start_index):
    count = 0
    for i in range(start_index, len(text)):
        if text[i] == '[':
            count += 1
        elif text[i] == ']':
            count -= 1
            if count == 0:
                return i
    return -1

def replace_category_block(filepath, is_overlay=False):
    with open(filepath, "r") as f:
        content = f.read()
        
    start_str = "if (widget.category != null) ...["
    idx = content.find(start_str)
    if idx == -1:
        # Check if already changed to categories
        start_str = "if (widget.categories != null) ...["
        idx = content.find(start_str)
        if idx == -1:
            print(f"Warning: {filepath} pattern not found!")
            return
            
    bracket_start = idx + len(start_str) - 1 # points to '['
    bracket_end = find_matching_bracket(content, bracket_start)
    
    new_ui = """if (widget.categories != null && widget.categories!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: widget.categories!.map((cat) => Container(
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
                              )).toList(),
                            ),
                          ]"""
    
    content = content[:idx] + new_ui + content[bracket_end+1:]
    
    # Also we need to fix any remaining references of `category` to `categories` in constructor
    content = content.replace("final String? category;", "final List<String>? categories;")
    content = content.replace("this.category,", "this.categories,")
    content = content.replace("String? category,", "List<String>? categories,")
    content = content.replace("category: category,", "categories: categories,")
    
    with open(filepath, "w") as f:
        f.write(content)

replace_category_block("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", True)
replace_category_block("lib/features/journey/presentation/screens/journey_detail_screen.dart", False)

