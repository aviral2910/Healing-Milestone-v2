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
  final TextEditingController _contentController = TextEditingController();
  int _selectedMonths = 6; // Default to 6 months
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _sealCapsule() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() { _isLoading = true; });

    try {
      final unlockDate = DateTime.now().add(Duration(days: _selectedMonths * 30));
      await ref.read(myTimeCapsulesProvider.notifier).addCapsule(
        _contentController.text.trim(),
        unlockDate,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Time Capsule sealed for $_selectedMonths months."),
            backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.9),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = const Color(0xFFFFC107); // Amber

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
              onPressed: _isLoading || _contentController.text.trim().isEmpty ? null : _sealCapsule,
              style: FilledButton.styleFrom(
                backgroundColor: baseColor,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
                  : const Text("Seal", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                        const SizedBox(width: 8),
                        Text(
                          "Unlock Date",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 3, 6, 12].map((months) {
                          final isSelected = _selectedMonths == months;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: ChoiceChip(
                              label: Text("$months Month${months > 1 ? 's' : ''}"),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() { _selectedMonths = months; });
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
