import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

final adminSubmissionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.dio.get('/api/admin/submissions');
  return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
});

class AdminSubmissionsScreen extends ConsumerWidget {
  const AdminSubmissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final submissionsAsync = ref.watch(adminSubmissionsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Web Submissions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminSubmissionsProvider),
          )
        ],
      ),
      body: SafeArea(
        child: submissionsAsync.when(
          loading: () => const Center(child: const AppLoader()),
          error: (error, stack) {
            return Center(
              child: Text(
                'Error loading submissions.\n$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          },
          data: (docs) {
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No submissions yet.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final data = docs[index];
                  final docId = data['id'];
                  
                  final name = data['name'] ?? 'Anonymous';
                  final isAnonymous = data['isAnonymous'] == true;
                  final displayName = isAnonymous ? '${data['preferredName'] ?? 'Anonymous'} (Hidden)' : name;
                  
                  final category = data['theme'] ?? 'General';
                  
                  final createdAtStr = data['createdAt'] as String?;
                  final dateStr = createdAtStr != null 
                      ? _formatDate(DateTime.parse(createdAtStr)) 
                      : 'Unknown Date';

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildSubmissionCard(
                          context: context,
                          theme: theme,
                          docId: docId,
                          data: data,
                          displayName: displayName,
                          category: category,
                          dateStr: dateStr,
                          isAnonymous: isAnonymous,
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
    );
  }

  Widget _buildSubmissionCard({
    required BuildContext context,
    required ThemeData theme,
    required String docId,
    required Map<String, dynamic> data,
    required String displayName,
    required String category,
    required String dateStr,
    required bool isAnonymous,
  }) {
    final mainStorySnippet = data['mainStory'] as String? ?? 'No story details provided...';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/admin-submissions/$docId', extra: data);
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
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
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                isAnonymous ? Icons.masks : Icons.person,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'By $displayName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  mainStorySnippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: theme.dividerColor.withValues(alpha: 0.1), height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Read More',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
