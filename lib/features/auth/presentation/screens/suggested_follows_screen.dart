import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repository_providers.dart';
import '../../data/auth_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


final suggestedUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repo = ref.read(userRepositoryProvider);
  return await repo.getSuggestedUsers();
});

class SuggestedFollowsScreen extends ConsumerStatefulWidget {
  const SuggestedFollowsScreen({super.key});

  @override
  ConsumerState<SuggestedFollowsScreen> createState() => _SuggestedFollowsScreenState();
}

class _SuggestedFollowsScreenState extends ConsumerState<SuggestedFollowsScreen> {
  bool _isSaving = false;
  late Set<String> _selectedUserIds;

  @override
  void initState() {
    super.initState();
    // Start with empty selections
    _selectedUserIds = {};
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
      final authNotifier = ref.read(authProvider.notifier);
      for (final userId in _selectedUserIds) {
        await authNotifier.toggleFollow(userId);
      }
      
      if (mounted) {
        context.go(AppRoutes.ascensionTransition);
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
    final suggestedUsersAsync = ref.watch(suggestedUsersProvider);
    
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
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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
              child: suggestedUsersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading suggestions')),
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(child: Text('No suggestions found.'));
                  }
                  return AnimationLimiter(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = _selectedUserIds.contains(user.userId);
                        
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    context.push(AppRoutes.publicProfile(user.userId));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.3) : theme.dividerColor.withValues(alpha: 0.2),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected 
                                              ? theme.colorScheme.primary.withValues(alpha: 0.05) 
                                              : Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppAvatar(
                                        radius: 28,
                                        role: user.role,
                                        imageUrl: user.profilePicture,
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
                                                    user.displayName,
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: theme.colorScheme.onSurface,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (user.isVerified) ...[
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
                                              '@${user.username}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (user.bio != null && user.bio!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                user.bio!,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.colorScheme.onSurface,
                                                  height: 1.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _FollowButton(
                                        isFollowing: isSelected,
                                        onTap: () => _toggleFollow(user.userId),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _finishOnboarding,
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
