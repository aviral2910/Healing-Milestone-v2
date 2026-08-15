import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';

class CreateTimeCapsuleScreen extends ConsumerStatefulWidget {
  const CreateTimeCapsuleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateTimeCapsuleScreen> createState() => _CreateTimeCapsuleScreenState();
}

class _CreateTimeCapsuleScreenState extends ConsumerState<CreateTimeCapsuleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int? _selectedMonths = 6; 
  DateTime? _customDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _sealCapsule() async {
    final theme = Theme.of(context);

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    DateTime unlockDate;
    if (_customDate != null) {
      unlockDate = _customDate!;
    } else {
      unlockDate = DateTime.now().add(Duration(days: (_selectedMonths ?? 6) * 30));
    }

    setState(() { _isLoading = true; });

    try {
      await ref.read(myTimeCapsulesProvider.notifier).addCapsule(
        title,
        content,
        unlockDate,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Time Capsule sealed!"),
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to seal capsule.")),
        );
      }
    }
  }
  
  Future<void> _pickCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 100)), // Up to 100 years!

    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedMonths = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton(
              onPressed: _isLoading || _titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty ? null : _sealCapsule,
              style: FilledButton.styleFrom(
                backgroundColor: baseColor,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary.withValues(alpha: 0.5)))
                  : Text("Seal", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: TextField(
                controller: _titleController,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Title (e.g. To my 30th Birthday Self)",
                  hintStyle: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const Divider(indent: 24, endIndent: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Dear future me...",
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 18,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_clock_rounded, color: baseColor),
                        SizedBox(width: 8),
                        Text(
                          "Unlock Date",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...[1, 3, 6, 12].map((months) {
                            final isSelected = _selectedMonths == months;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: ChoiceChip(
                                label: Text("$months Month${months > 1 ? 's' : ''}"),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedMonths = months;
                                      _customDate = null;
                                    });
                                  }
                                },
                                selectedColor: baseColor.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: isSelected ? baseColor : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? baseColor : theme.colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          ChoiceChip(
                            label: Text(_customDate != null 
                                ? _customDate!.toLocal().toString().split(' ')[0] 
                                : "Custom Date"),
                            selected: _customDate != null,
                            onSelected: (_) => _pickCustomDate(),
                            selectedColor: baseColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: _customDate != null ? baseColor : theme.colorScheme.onSurface,
                              fontWeight: _customDate != null ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _customDate != null ? baseColor : theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
