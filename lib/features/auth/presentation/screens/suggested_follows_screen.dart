import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/models/user_model.dart';
import '../../data/auth_provider.dart';

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
    }
  ];

  late Set<String> _selectedUserIds;

  @override
  void initState() {
    super.initState();
    // Default select everyone, especially the admin
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
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
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
                    'Based on your interests, here are some inspiring journeys and top doctors to follow.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _suggestedUsers.length,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  final user = _suggestedUsers[index];
                  final isSelected = _selectedUserIds.contains(user['id']);
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          user['role'] == UserRole.healthcareProfessional 
                              ? Icons.local_hospital_rounded 
                              : (user['role'] == UserRole.organization ? Icons.health_and_safety : Icons.person),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user['displayName'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
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
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user['bio'],
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _toggleFollow(user['id']),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          foregroundColor: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          isSelected ? 'Following' : 'Follow',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                          'Let\'s Begin',
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
