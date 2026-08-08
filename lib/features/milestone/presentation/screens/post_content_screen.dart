import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/post_creation_state.dart';

class PostContentScreen extends StatefulHookConsumerWidget {
  const PostContentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostContentScreen> createState() => _PostContentScreenState();
}

class _PostContentScreenState extends ConsumerState<PostContentScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () {
            ref.read(postCreationControllerProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Text(
          'New Post',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _buildEntrySelection(theme),
      ),
    );
  }

  Widget _buildEntrySelection(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 48, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Text(
              'How would you like to start?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a path to begin sharing your milestone.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildChoiceCard(
              theme: theme,
              icon: Icons.auto_awesome,
              title: 'Guided Story (AI)',
              subtitle: 'Answer a few simple questions and let our AI draft an inspiring, deeply felt story for you.',
              isHighlighted: true,
              onTap: () {
                context.push(AppRoutes.createPostGuided);
              },
            ),
            const SizedBox(height: 20),
            _buildChoiceCard(
              theme: theme,
              icon: Icons.edit_note_rounded,
              title: 'Write Freely',
              subtitle: 'Start with a blank canvas and share your story entirely your way.',
              onTap: () {
                context.push(AppRoutes.createPostManual);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: isHighlighted
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.dividerColor.withValues(alpha: 0.3),
            width: isHighlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
          color: isHighlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isHighlighted
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      
                      color: isHighlighted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
