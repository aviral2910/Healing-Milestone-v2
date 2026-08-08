import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AdminSubmissionDetailScreen extends ConsumerWidget {
  final String submissionId;
  final Map<String, dynamic> data;

  const AdminSubmissionDetailScreen({
    Key? key,
    required this.submissionId,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    
    final name = data['name'] ?? 'Anonymous';
    final isAnonymous = data['isAnonymous'] == true;
    final displayName = isAnonymous ? '${data['preferredName'] ?? 'Anonymous'} (Hidden: $name)' : name;
    
    final category = data['theme'] ?? 'General';
    final mainStory = data['mainStory'] ?? 'No story provided';
    final struggle = data['theStruggle'] ?? 'None provided';
    final turningPoint = data['theTurningPoint'] ?? 'None provided';
    final lesson = data['theLesson'] ?? 'None provided';
    final email = data['email'] ?? 'No email';

    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Story Details',
          style: themeData.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildContactCard(themeData, displayName, email, isAnonymous),
                const SizedBox(height: 24),
                _buildStoryCard(
                  themeData, 
                  title: 'Theme & Main Story', 
                  icon: Icons.auto_stories,
                  content: [
                    _buildContentRow(themeData, 'Theme', category),
                    _buildContentRow(themeData, 'Main Story', mainStory, isLast: true),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStoryCard(
                  themeData, 
                  title: 'Deeper Narrative', 
                  icon: Icons.psychology,
                  content: [
                    _buildContentRow(themeData, 'The Struggle', struggle),
                    _buildContentRow(themeData, 'The Turning Point', turningPoint),
                    _buildContentRow(themeData, 'The Lesson', lesson, isLast: true),
                  ],
                ),
                const SizedBox(height: 48),
                _buildCTAButton(context, themeData),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(ThemeData theme, String name, String email, bool isAnonymous) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(
              isAnonymous ? Icons.masks : Icons.person,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(ThemeData theme, {required String title, required IconData icon, required List<Widget> content}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor.withValues(alpha: 0.1), height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRow(ThemeData theme, String label, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(AppRoutes.createPostGuided, extra: data);
        },
        icon: Icon(Icons.auto_awesome, color: theme.colorScheme.onPrimary),
        label: Text(
          'Create AI Story',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            
            color: theme.colorScheme.onPrimary,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
