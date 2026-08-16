import 'package:cached_network_image/cached_network_image.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/comment_model.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/posts/data/paginated_comments_provider.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';

class CommentsThread extends ConsumerStatefulWidget {
  final StoryModel milestone;

  const CommentsThread({Key? key, required this.milestone}) : super(key: key);

  @override
  ConsumerState<CommentsThread> createState() => _CommentsThreadState();
}

class _CommentsThreadState extends ConsumerState<CommentsThread> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push(AppRoutes.login);
      return;
    }

    final comment = CommentModel(
      commentId: '', // Set by backend
      storyId: widget.milestone.storyId,
      commentText: text,
      userId: user.userId,
      createdAt: DateTime.now(),
    );

    _commentController.clear();

    // Add comment to backend
    await ref.read(commentRepositoryProvider).addComment(comment);

    // Refresh the comments list instantly
    ref.invalidate(paginatedCommentsProvider(widget.milestone.storyId));
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(
      paginatedCommentsProvider(widget.milestone.storyId),
    );
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commentsAsync.when(
          data: (response) {
            final comments = response.items;
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No comments yet. Be the first!',
                  style: TextStyle(
                    color:
                        (Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey),
                  ),
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _CommentBubble(
                          comment: comment,
                          storyOwnerId: widget.milestone.authorId,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Error loading comments: $e'),
        ),
        const SizedBox(height: 24),
        // Add Comment Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(
                    color:
                        (Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _submitComment,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommentBubble extends ConsumerWidget {
  final CommentModel comment;
  final String storyOwnerId;

  const _CommentBubble({
    Key? key,
    required this.comment,
    required this.storyOwnerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = comment.user != null
        ? AsyncData<UserModel?>(comment.user)
        : ref.watch(userByIdProvider(comment.userId));
    final currentUser = ref.watch(currentUserProvider);

    final isCommentOwner = currentUser?.userId == comment.userId;
    final isStoryOwner = currentUser?.userId == storyOwnerId;
    final canDelete = isCommentOwner || isStoryOwner;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        userAsync.when(
          data: (user) {
            return CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              backgroundImage: user?.profilePicture != null
                  ? CachedNetworkImageProvider(
                      user!.profilePicture!,
                      maxHeight: 200,
                    )
                  : CachedNetworkImageProvider(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=${comment.userId}',
                      maxHeight: 200,
                    ),
              radius: 18,
            );
          },
          loading: () => CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            radius: 18,
          ),
          error: (_, __) => CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            radius: 18,
            child: const Icon(Icons.error, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onLongPress: canDelete
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        title: Text(
                          'Delete Comment',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete this comment?',
                          style: TextStyle(
                            color:
                                (Theme.of(context).textTheme.bodySmall?.color ??
                                Colors.grey),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color:
                                    (Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color ??
                                    Colors.grey),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final storyId = comment.storyId;
                              Navigator.pop(context); // Close dialog first

                              await ref
                                  .read(commentRepositoryProvider)
                                  .deleteComment(storyId, comment.commentId);

                              // Refresh the comments list instantly
                              ref.invalidate(
                                paginatedCommentsProvider(storyId),
                              );
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsync.when(
                    data: (user) => Text(
                      user?.displayName ?? '@${user?.username ?? 'Anonymous'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            (Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.grey),
                      ),
                    ),
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Error'),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment.commentText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
