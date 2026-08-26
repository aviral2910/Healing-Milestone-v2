import re
import os

# --- 1. Fix public_journey_detail_overlay.dart ---
with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "r") as f:
    content = f.read()

# Fix the first crash: .first.authorRole
content = content.replace("milestonesAsync\n                                            .value\n                                            ?.items\n                                            .first\n                                            .authorRole,", "(milestonesAsync.value?.items.isNotEmpty == true ? milestonesAsync.value!.items.first.authorRole : null),")
content = content.replace("milestonesAsync.value?.items.first.authorRole", "(milestonesAsync.value?.items.isNotEmpty == true ? milestonesAsync.value!.items.first.authorRole : null)")
content = content.replace("milestonesAsync\n                                                .value\n                                                ?.items\n                                                .first\n                                                .authorTitle,", "(milestonesAsync.value?.items.isNotEmpty == true ? milestonesAsync.value!.items.first.authorTitle : null),")

# Replace category with categories
content = content.replace("final String? category;", "final List<String>? categories;")
content = content.replace("this.category,", "this.categories,")
content = content.replace("String? category,", "List<String>? categories,")
content = content.replace("category: category,", "categories: categories,")

# Now find where category is displayed
# It might look like:
# Text(
#   widget.category ?? 'General',
old_cat_display = r"Text\(\s*widget\.category \?\? 'General',\s*style: theme\.textTheme\.labelMedium\?\.copyWith\(\s*color: theme\.colorScheme\.primary,\s*fontWeight: FontWeight\.w600,\s*\),\s*\)"
new_cat_display = """Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children: (widget.categories != null && widget.categories!.isNotEmpty ? widget.categories! : ['General']).map((cat) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$cat',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )).toList(),
                              )"""
content = re.sub(old_cat_display, new_cat_display, content)

with open("lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart", "w") as f:
    f.write(content)

# --- 2. Fix journey_detail_screen.dart ---
with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

content = content.replace("final String? category;", "final List<String>? categories;")
content = content.replace("this.category,", "this.categories,")

old_cat_display2 = r"Text\(\s*widget\.category \?\? 'General',\s*style: theme\.textTheme\.labelMedium\?\.copyWith\(\s*color: theme\.colorScheme\.primary,\s*fontWeight: FontWeight\.w500,\s*\),\s*\)"
new_cat_display2 = """Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children: (widget.categories != null && widget.categories!.isNotEmpty ? widget.categories! : ['General']).map((cat) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$cat',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )).toList(),
                              )"""
content = re.sub(old_cat_display2, new_cat_display2, content)

# Check if there is another place where it's used
# Like in _buildEmptyState
# Actually, it's just the header

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)

# --- 3. Fix callers ---
for root, _, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, "r") as f:
                c = f.read()
            
            # replace category: journey.categories.first etc to categories: journey.categories
            if "category: " in c and ("PublicJourneyDetailOverlay.show" in c or "JourneyDetailScreen" in c):
                # We can do some manual replacements
                # Usually it's: category: journey.categories.isNotEmpty ? journey.categories.first : 'General'
                # or category: widget.(milestone.journeyCategories?.isNotEmpty == true ? widget.milestone.journeyCategories!.first : null),
                
                c = re.sub(r"category:\s*journey\.categories\.isNotEmpty\s*\?\s*journey\.categories\.first\s*:\s*'General',", "categories: journey.categories,", c)
                c = re.sub(r"category:\s*widget\.milestone\.journeyCategories\?\.isNotEmpty\s*==\s*true\s*\?\s*widget\.milestone\.journeyCategories!\.first\s*:\s*null,", "categories: widget.milestone.journeyCategories,", c)
                # also the fixed one: category: (widget.milestone.journeyCategories?.isNotEmpty == true ? widget.milestone.journeyCategories!.first : null),
                c = c.replace("category: (widget.milestone.journeyCategories?.isNotEmpty == true ? widget.milestone.journeyCategories!.first : null),", "categories: widget.milestone.journeyCategories,")
                
                with open(filepath, "w") as f:
                    f.write(c)

