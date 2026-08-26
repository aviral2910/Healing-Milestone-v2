import re

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "r") as f:
    content = f.read()

old_state = """class _LogMilestoneOverlayState extends ConsumerState<LogMilestoneOverlay> {
  final _contentController = TextEditingController();
  EmotionStatus? _selectedEmotion;
  ProfessionalTag? _selectedTag;
  bool _isReopening = false;
  bool _isClosure = false;
  bool _isLoading = false;"""

new_state = """class _LogMilestoneOverlayState extends ConsumerState<LogMilestoneOverlay> {
  final _contentController = TextEditingController();
  EmotionStatus? _selectedEmotion;
  EmotionCategory _selectedCategory = EmotionCategory.positive;
  ProfessionalTag? _selectedTag;
  bool _isReopening = false;
  bool _isClosure = false;
  bool _isLoading = false;"""

content = content.replace(old_state, new_state)

old_ui = """                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            child: Row(
                              children: [
                                _buildEmotionChip(EmotionStatus.hopeful),
                                const SizedBox(width: 12),
                                _buildEmotionChip(EmotionStatus.proud),
                                const SizedBox(width: 12),
                                _buildEmotionChip(EmotionStatus.neutral),
                                const SizedBox(width: 12),
                                _buildEmotionChip(EmotionStatus.anxious),
                                const SizedBox(width: 12),
                                _buildEmotionChip(EmotionStatus.grieving),
                              ],
                            ),
                          ),"""

new_ui = """                          // Category Selector
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

content = content.replace(old_ui, new_ui)

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "w") as f:
    f.write(content)
