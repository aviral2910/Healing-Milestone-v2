new_content = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/models/user_model.dart';
import '../../data/auth_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';

class SuggestedFollowsScreen extends ConsumerStatefulWidget {
  const SuggestedFollowsScreen({super.key});

  @override
  ConsumerState<SuggestedFollowsScreen> createState() => _SuggestedFollowsScreenState();
}

class _SuggestedFollowsScreenState extends ConsumerState<SuggestedFollowsScreen> {
  bool _isSaving = false;
  
  // Hardcoded for now. In Phase 4 this will be fetched from API based on interests.
  final List<Map<String, dynamic>> _suggestedUsers = [
    {
      'id': 'admin',
      'username': 'healingmilestones',
      'displayName': 'Healing Milestones',
      'role': UserRole.organization,
      'isVerified': true,
      'bio': 'The official account for app updates, tutorials, and featured stories.',
    },
    {
      'id': 'dr_smith',
      'username': 'dr_sarah_smith',
      'displayName': 'Dr. Sarah Smith',
      'role': UserRole.healthcareProfessional,
      'isVerified': true,
      'bio': 'Clinical Psychologist specializing in trauma, PTSD, and anxiety management.',
    },
    {
      'id': 'wellness_journey',
      'username': 'wellness_journey',
      'displayName': 'Wellness Journey',
      'role': UserRole.patient,
      'isVerified': false,
      'bio': 'Sharing my personal journey of overcoming depression and finding daily joy.',
    }
  ];

  late Set<String> _selectedUserIds;

  @override
  void initState() {
    super.initState();
    // Default select everyone initially
    _selectedUserIds = _suggestedUsers.map((u) => u['id'] as String).toSet();
  }

  void _toggleFollow(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  Future<void> _finishOnboarding() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // In a real implementation, we would call an API to bulk follow these users
      // For now, we simulate the network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        // Force the router to evaluate the new state and go home
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to follow users: $e')),
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested for you',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Based on your interests, here are some inspiring journeys and experts to follow.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _suggestedUsers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = _suggestedUsers[index];
                  final isSelected = _selectedUserIds.contains(user['id']);
                  
                  // Tween animation builder for a subtle entry slide
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppAvatar(
                            radius: 28,
                            role: user['role'],
                            imageUrl: user['profilePicture'],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user['displayName'],
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (user['isVerified'] == true) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${user['username']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user['bio'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _FollowButton(
                            isFollowing: isSelected,
                            onTap: () => _toggleFollow(user['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _finishOnboarding,
                  style: FilledButton.styleFrom(
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
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing 
              ? theme.colorScheme.surfaceContainerHighest 
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFollowing 
                ? theme.dividerColor 
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isFollowing 
                ? theme.colorScheme.onSurface 
                : theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
"""
with open("lib/features/auth/presentation/screens/suggested_follows_screen.dart", "w") as f:
    f.write(new_content)
