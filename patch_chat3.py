import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Add _buildSharedProfileCard
old_end = """        ],
      ),
    );
  }
}"""

new_end = """        ],
      ),
    );
  }

  Widget _buildSharedProfileCard({
    required BuildContext context,
    required WidgetRef ref,
    required String profileId,
    required bool isMe,
  }) {
    final fgColor = isMe ? Colors.white : Colors.black87;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.05);

    final userAsync = ref.watch(userByIdProvider(profileId));

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: userAsync.when(
        data: (user) {
          if (user == null) return const Text('User not found');
          return Row(
            children: [
              AppAvatar(imageUrl: user.profilePicture, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.username != null)
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 12,
                          color: fgColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Error loading profile'),
      ),
    );
  }
}"""
content = content.replace(old_end, new_end)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
