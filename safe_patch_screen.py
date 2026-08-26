with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

# Replace class signature
old_class_sig = """class JourneyDetailScreen extends ConsumerWidget {
  final String journeyId;
  final String title;
  final String? category;
  final MilestoneVisibility? visibility;
  final bool isMine;

  const JourneyDetailScreen({
    Key? key,
    required this.journeyId,
    required this.title,
    this.category,
    this.visibility,
    this.isMine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {"""

new_class_sig = """class JourneyDetailScreen extends ConsumerStatefulWidget {
  final String journeyId;
  final String title;
  final String? category;
  final MilestoneVisibility? visibility;
  final bool isMine;

  const JourneyDetailScreen({
    Key? key,
    required this.journeyId,
    required this.title,
    this.category,
    this.visibility,
    this.isMine = false,
  }) : super(key: key);

  @override
  ConsumerState<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends ConsumerState<JourneyDetailScreen> {
  MilestoneVisibility? _currentVisibility;
  bool _isUpdatingVisibility = false;

  @override
  void initState() {
    super.initState();
    _currentVisibility = widget.visibility;
  }

  IconData _getVisibilityIcon(MilestoneVisibility? vis) {
    switch (vis) {
      case MilestoneVisibility.public: return Icons.public;
      case MilestoneVisibility.private: return Icons.lock_outline;
      case MilestoneVisibility.anonymous: return Icons.masks;
      default: return Icons.public;
    }
  }
  
  String _getVisibilityText(MilestoneVisibility vis) {
    switch (vis) {
      case MilestoneVisibility.public: return 'Public';
      case MilestoneVisibility.private: return 'Private';
      case MilestoneVisibility.anonymous: return 'Anonymous';
    }
  }

  void _showVisibilityBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('Journey Visibility', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final vis in MilestoneVisibility.values)
                  ListTile(
                    leading: Icon(_getVisibilityIcon(vis)),
                    title: Text(_getVisibilityText(vis)),
                    trailing: _currentVisibility == vis
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : null,
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      if (_currentVisibility != vis) {
                        setState(() { _isUpdatingVisibility = true; });
                        try {
                          await ref.read(journeyRepositoryProvider).updateJourneyVisibility(widget.journeyId, vis);
                          if (mounted) {
                            setState(() { _currentVisibility = vis; });
                            ref.invalidate(userJourneysProvider);
                            ref.invalidate(myJourneysProvider);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update visibility')));
                          }
                        } finally {
                          if (mounted) {
                            setState(() { _isUpdatingVisibility = false; });
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {"""

content = content.replace(old_class_sig, new_class_sig)

# Now, we carefully replace the local usages inside the build method.
# `journeyId` -> `widget.journeyId`
content = content.replace("paginatedJourneyMilestonesProvider(journeyId)", "paginatedJourneyMilestonesProvider(widget.journeyId)")
content = content.replace("journeyId: journeyId", "journeyId: widget.journeyId")
content = content.replace("showJourneyShareOptions(context, journeyId, title)", "showJourneyShareOptions(context, widget.journeyId, widget.title)")

# `title` -> `widget.title`
content = content.replace("Text(title,", "Text(widget.title,")

# `category` -> `widget.category`
content = content.replace("if (category != null)", "if (widget.category != null)")
content = content.replace("Text(category!,", "Text(widget.category!,")

# Actions section
old_actions = """            actions: [
              if (visibility == MilestoneVisibility.public)
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share Journey',
                  onPressed: () {
                    showJourneyShareOptions(context, widget.journeyId, widget.title);
                  },
                ),"""

new_actions = """            actions: [
              if (widget.isMine)
                _isUpdatingVisibility
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: Icon(_getVisibilityIcon(_currentVisibility)),
                        tooltip: 'Change Visibility',
                        onPressed: _showVisibilityBottomSheet,
                      ),
              if (_currentVisibility == MilestoneVisibility.public)
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share Journey',
                  onPressed: () {
                    showJourneyShareOptions(context, widget.journeyId, widget.title);
                  },
                ),"""

content = content.replace(old_actions, new_actions)

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)
