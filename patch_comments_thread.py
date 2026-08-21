with open("lib/features/milestone/presentation/widgets/comments_thread.dart", "r") as f:
    content = f.read()

# Make it take up full height by replacing shrinkWrap and Column
old_build = """  @override
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
                itemCount: comments.length,"""

new_build = """  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(
      paginatedCommentsProvider(widget.milestone.storyId),
    );
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (response) {
                final comments = response.items;
                if (comments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(
                          color:
                              (Theme.of(context).textTheme.bodySmall?.color ??
                              Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,"""
                    
content = content.replace(old_build, new_build)

old_build_end = """                },
              ),
            );
          },
          loading:
              () => const Center(
                child: AppLoader(size: 30),
              ),
          error:
              (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading comments: $err'),
              ),
        ),
        const SizedBox(height: 24),
        // Input Field
        _buildCommentInput(theme),
      ],
    );
  }"""

new_build_end = """                },
              ),
            );
          },
          loading:
              () => const Center(
                child: AppLoader(size: 30),
              ),
          error:
              (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading comments: $err'),
              ),
            ),
          ),
          // Input Field
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: _buildCommentInput(theme),
            ),
          ),
        ],
      ),
    );
  }"""

content = content.replace(old_build_end, new_build_end)

helper_method = """void showCommentsBottomSheet(BuildContext context, StoryModel story) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Grabber handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Comments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Expanded(child: CommentsThread(milestone: story)),
          ],
        );
      },
    ),
  );
}
"""

content = content + "\n\n" + helper_method

with open("lib/features/milestone/presentation/widgets/comments_thread.dart", "w") as f:
    f.write(content)
