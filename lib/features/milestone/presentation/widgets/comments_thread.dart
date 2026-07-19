import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/models/comment_model.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
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

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login');
      return;
    }

    final comment = CommentModel(
      commentId: '', // Set by backend
      storyId: widget.milestone.storyId,
      commentText: text,
      userId: user.userId,
      createdAt: DateTime.now(),
    );

    ref.read(commentRepositoryProvider).addComment(comment);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(storyCommentsProvider(widget.milestone.storyId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No comments yet. Be the first!',
                  style: TextStyle(color: const Color(0xFFA1A1A6)),
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _CommentBubble(comment: comment),
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
                style: const TextStyle(color: Color(0xFFF5F5F7)),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: const TextStyle(color: Color(0xFFA1A1A6)),
                  filled: true,
                  fillColor: const Color(0xFF151515),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
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

  const _CommentBubble({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(comment.userId));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        userAsync.when(
          data: (user) {
            return CircleAvatar(
              backgroundColor: const Color(0xFF1E1E1E),
              backgroundImage: user?.profilePicture != null 
                  ? NetworkImage(user!.profilePicture!) 
                  : NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${comment.userId}'),
              radius: 18,
            );
          },
          loading: () => const CircleAvatar(
            backgroundColor: Color(0xFF1E1E1E),
            radius: 18,
          ),
          error: (_, __) => const CircleAvatar(
            backgroundColor: Color(0xFF1E1E1E),
            radius: 18,
            child: Icon(Icons.error, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              border: Border.all(color: const Color(0xFF2A2A2A)),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA1A1A6),
                    ),
                  ),
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error'),
                ),
                const SizedBox(height: 6),
                Text(
                  comment.commentText,
                  style: const TextStyle(color: Color(0xFFF5F5F7), height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
