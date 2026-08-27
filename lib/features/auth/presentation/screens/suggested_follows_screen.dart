import 'package:flutter/material.dart';
import 'dart:ui';
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
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: suggestedUsersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Center(child: Text('Error loading suggestions')),
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(child: Text('No suggestions found.'));
                  }
                  return AnimationLimiter(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
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
                                const SizedBox(height: 8),
                                Text(
                                  'Based on your interests, here are some inspiring journeys and experts to follow.',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final user = users[index];
                                final isSelected = _selectedUserIds.contains(user.userId);
                                
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            context.push(AppRoutes.publicProfile(user.userId));
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? theme.colorScheme.primary.withValues(alpha: 0.05)
                                                  : theme.colorScheme.surface,
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(
                                                color: isSelected 
                                                    ? theme.colorScheme.primary.withValues(alpha: 0.3) 
                                                    : theme.dividerColor.withValues(alpha: 0.1),
                                                width: 1.0,
                                              ),
                                              boxShadow: isSelected ? [] : [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.02),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                                              Flexible(
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
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (user.bio != null && user.bio!.isNotEmpty) ...[
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    user.bio!,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.colorScheme.onSurface,
                                                      height: 1.3,
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                const SizedBox(height: 16),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: _FollowButton(
                                                    isFollowing: isSelected,
                                                    onTap: () => _toggleFollow(user.userId),
                                                  ),
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
                              childCount: users.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for floating button
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Glassmorphism Button Container
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _finishOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                          : Text(
                              _selectedUserIds.isEmpty ? 'Skip' : 'Follow ${_selectedUserIds.length} & Continue',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing 
              ? theme.colorScheme.surfaceContainerHighest 
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFollowing 
                ? theme.dividerColor.withValues(alpha: 0.5) 
                : Colors.transparent,
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
