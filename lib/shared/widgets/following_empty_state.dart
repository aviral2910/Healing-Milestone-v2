import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class FollowingEmptyStateWidget extends StatelessWidget {
  const FollowingEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Your personal feed is quiet!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Follow inspiring journeys and Top Doctors to fill your feed with updates that matter to you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Navigate back to the "For You" tab or Suggested Follows
                // For now, we can route them to Discover/Search or let them manually swipe
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Swipe left to Discover new accounts!')),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Discover Accounts'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: BorderSide(color: theme.colorScheme.primary),
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
