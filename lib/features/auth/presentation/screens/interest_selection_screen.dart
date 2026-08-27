import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/hashtag_repository.dart';

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends ConsumerState<InterestSelectionScreen> {
  final List<String> _availableInterests = [
    'Anxiety', 'Depression', 'Migraines', 'Diabetes', 
    'Chronic Pain', 'Fitness', 'Sleep', 'Gut Health', 
    'Heart Health', 'Pregnancy', 'Menopause', 'PCOS',
    'ADHD', 'PTSD', 'Weight Loss', 'Nutrition'
  ];
  
  final Set<String> _selectedInterests = {};
  bool _isSaving = false;

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 3 interests.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authState = ref.read(authProvider).value;
      final userModel = authState?.userModel;
      
      if (userModel != null) {
        final updatedUser = userModel.copyWith(
          interests: _selectedInterests.toList(),
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }
      
      if (mounted) {
        context.push(AppRoutes.suggestedFollows);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save interests: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendingAsync = ref.watch(trendingHashtagsProvider);
    final trendingTags = trendingAsync.value ?? [];
    
    // Combine core and trending tags
    final combinedList = <String>[..._availableInterests];
    for (final tag in trendingTags) {
        if (!combinedList.any((t) => t.toLowerCase() == tag.toLowerCase())) {
            combinedList.add(tag);
        }
    }
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What brings you here?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select at least 3 topics so we can personalize your experience.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 16.0,
                    children: combinedList.map((interest) {
                      final isTrending = trendingTags.contains(interest) && !_availableInterests.contains(interest);
                      final displayLabel = isTrending ? '🔥 $interest' : interest;
                      final isSelected = _selectedInterests.contains(interest);
                      return ChoiceChip(
                        label: Text(
                          displayLabel,
                          style: TextStyle(
                            color: isSelected 
                                ? theme.colorScheme.onPrimary 
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => _toggleInterest(interest),
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected 
                                ? Colors.transparent 
                                : theme.dividerColor,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedInterests.length >= 3 && !_isSaving)
                      ? _saveAndContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
