with open("lib/features/profile/presentation/screens/public_profile_screen.dart", "r") as f:
    content = f.read()

# Add chat imports if missing
if "healing_milestones/features/chat/presentation/providers/chat_providers.dart" not in content:
    content = content.replace(
        "import 'package:healing_milestones/features/auth/presentation/providers/auth_providers.dart';",
        "import 'package:healing_milestones/features/auth/presentation/providers/auth_providers.dart';\nimport 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';\nimport 'package:healing_milestones/features/chat/presentation/screens/chat_room_screen.dart';"
    )

# Replace the single button with a Row
old_action_buttons = """                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (currentUser == null) {
                                      context.push(AppRoutes.login);
                                    } else {
                                      await ref
                                          .read(authProvider.notifier)
                                          .toggleFollow(user.userId);
                                      ref.invalidate(
                                        isFollowingProvider(user.userId),
                                      );

                                      // Await the refresh to prevent UI flickering
                                      await ref.refresh(
                                        userStreamProvider(
                                          currentUser.userId,
                                        ).future,
                                      );
                                      ref.invalidate(
                                        userByIdProvider(user.userId),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFollowing
                                        ? theme.dividerColor
                                        : theme.colorScheme.primary,
                                    foregroundColor: isFollowing
                                        ? theme.textTheme.bodyMedium?.color
                                        : (theme.colorScheme.primary
                                                      .computeLuminance() >
                                                  0.25
                                              ? Colors.black
                                              : Colors.white),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    isFollowing ? 'Following' : 'Follow',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );"""

new_action_buttons = """                              return Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (currentUser == null) {
                                          context.push(AppRoutes.login);
                                        } else {
                                          await ref
                                              .read(authProvider.notifier)
                                              .toggleFollow(user.userId);
                                          ref.invalidate(
                                            isFollowingProvider(user.userId),
                                          );
    
                                          // Await the refresh to prevent UI flickering
                                          await ref.refresh(
                                            userStreamProvider(
                                              currentUser.userId,
                                            ).future,
                                          );
                                          ref.invalidate(
                                            userByIdProvider(user.userId),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFollowing
                                            ? theme.dividerColor
                                            : theme.colorScheme.primary,
                                        foregroundColor: isFollowing
                                            ? theme.textTheme.bodyMedium?.color
                                            : (theme.colorScheme.primary
                                                          .computeLuminance() >
                                                      0.25
                                                  ? Colors.black
                                                  : Colors.white),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: Text(
                                        isFollowing ? 'Following' : 'Follow',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (currentUser == null) {
                                          context.push(AppRoutes.login);
                                          return;
                                        }
                                        try {
                                          // Request chat permission from FastAPI
                                          await ref.read(chatRepositoryProvider).requestChat(user.userId);
                                          // In a real app we'd get the roomId back and navigate. 
                                          // For now, let's just show a snackbar or navigate to inbox.
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Chat request sent! Check your inbox.')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Could not start chat: $e')),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primaryContainer,
                                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Text(
                                        'Message',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );"""

content = content.replace(old_action_buttons, new_action_buttons)

with open("lib/features/profile/presentation/screens/public_profile_screen.dart", "w") as f:
    f.write(content)

