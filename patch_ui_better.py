import re

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "r") as f:
    content = f.read()

# 1. Add _buildCategoryChip
old_method = "  Widget _buildEmotionChip(EmotionStatus status) {"
new_method = """  Widget _buildCategoryChip(EmotionCategory category, String label) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionChip(EmotionStatus status) {"""

content = content.replace(old_method, new_method)

# 2. Update the build method
old_ui = """                          // Category Selector
                          SegmentedButton<EmotionCategory>(
                            segments: const [
                              ButtonSegment(
                                value: EmotionCategory.positive,
                                label: Text('Uplifting'),
                              ),
                              ButtonSegment(
                                value: EmotionCategory.negative,
                                label: Text('Heavy'),
                              ),
                              ButtonSegment(
                                value: EmotionCategory.neutral,
                                label: Text('Neutral'),
                              ),
                            ],
                            selected: {_selectedCategory},
                            onSelectionChanged: (Set<EmotionCategory> newSelection) {
                              setState(() {
                                _selectedCategory = newSelection.first;
                              });
                            },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Emotion Chips for selected category
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: EmotionStatus.values
                                  .where((e) => e.category == _selectedCategory)
                                  .map((e) => _buildEmotionChip(e))
                                  .toList(),
                            ),
                          ),"""

new_ui = """                          // Custom Category Selector
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                _buildCategoryChip(EmotionCategory.positive, 'Uplifting'),
                                const SizedBox(width: 8),
                                _buildCategoryChip(EmotionCategory.negative, 'Challenging'),
                                const SizedBox(width: 8),
                                _buildCategoryChip(EmotionCategory.neutral, 'Neutral'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Emotion Chips for selected category (Scrolling)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: EmotionStatus.values
                                  .where((e) => e.category == _selectedCategory)
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                        child: _buildEmotionChip(e),
                                      ))
                                  .toList(),
                            ),
                          ),"""

content = content.replace(old_ui, new_ui)

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "w") as f:
    f.write(content)
