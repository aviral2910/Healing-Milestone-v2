import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/hashtag_repository.dart';

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState
    extends ConsumerState<InterestSelectionScreen> {
  final Map<String, List<String>> _categorizedInterests = {
    '🧠 Mental & Emotional Health': [
      'Anxiety', 'Depression', 'PTSD', 'Trauma Recovery', 'Grief & Loss', 
      'Burnout', 'Panic Attacks', 'Bipolar Disorder', 'Insomnia', 
      'Stress Management', 'Addiction Recovery'
    ],
    '🏃‍♂️ Chronic Illness & Pain': [
      'Chronic Pain', 'Fibromyalgia', 'Migraines', 'Long Covid', 
      'Diabetes', 'Arthritis', 'Chronic Fatigue', 'Lupus', 'POTS'
    ],
    '🍎 Gut Health & Nutrition': [
      'Gut Health', 'IBS', 'Celiac Disease', "Crohn's & Colitis", 
      'Food Allergies', 'Weight Loss', 'Eating Disorder Recovery', 
      'Anti-Inflammatory Diet'
    ],
    '👶 Women\'s Health & Family': [
      'Pregnancy', 'Postpartum', 'Menopause', 'PCOS', 'Endometriosis', 
      'Fertility Journey', 'Motherhood'
    ],
    '🧬 Neurodivergence & Cognitive': [
      'ADHD', 'Autism', 'Brain Fog', 'Concussion Recovery'
    ],
    '🧘‍♀️ Lifestyle, Wellness & Holistic': [
      'Fitness', 'Sleep Hygiene', 'Meditation', 'Yoga for Healing', 
      'Breathwork', 'Somatic Healing', 'Physical Therapy'
    ],
    '🤝 Support & Relationships': [
      'Caregiving', 'Setting Boundaries', 'Narcissistic Abuse Recovery', 
      'Finding Community'
    ],
  };

  final Set<String> _selectedInterests = {};
  bool _isSaving = false;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save interests: $e')));
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

        final Map<String, List<String>> displayCategories = {};
    
    // 1. Add Trending Tags first (if available)
    if (trendingTags.isNotEmpty) {
      // Limit trending tags to top 10
      displayCategories['🔥 Trending Now'] = trendingTags.take(10).toList();
    }
    
    // 2. Add all other categories
    displayCategories.addAll(_categorizedInterests);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What are you navigating right now?',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Select at least 3 topics so we can build a personalized feed of stories and journeys that matter to you.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final categoryEntry = displayCategories.entries.elementAt(index);
                          final categoryName = categoryEntry.key;
                          final tags = categoryEntry.value;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10.0,
                                  runSpacing: 12.0,
                                  children: tags.map((interest) {
                                    final isSelected = _selectedInterests.any(
                                      (selected) => selected.toLowerCase() == interest.toLowerCase()
                                    );
                                    
                                    return ChoiceChip(
                                      label: Text(
                                        interest,
                                        style: TextStyle(
                                          color: isSelected 
                                              ? theme.colorScheme.onPrimary 
                                              : theme.colorScheme.onSurface,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          final match = _selectedInterests.where(
                                            (s) => s.toLowerCase() == interest.toLowerCase()
                                          ).firstOrNull;
                                          
                                          if (match != null) {
                                            _selectedInterests.remove(match);
                                          } else {
                                            _selectedInterests.add(interest);
                                          }
                                        });
                                      },
                                      selectedColor: theme.colorScheme.primary,
                                      backgroundColor: theme.colorScheme.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected 
                                              ? Colors.transparent 
                                              : theme.dividerColor.withValues(alpha: 0.6),
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: displayCategories.length,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                ),
                child: ElevatedButton(
                  onPressed: (_selectedInterests.length >= 3 && !_isSaving)
                      ? _saveAndContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
