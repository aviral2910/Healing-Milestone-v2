import re

with open('lib/features/profile/presentation/screens/public_profile_screen.dart', 'r') as f:
    content = f.read()

old_request = """                                        try {
                                          // Request chat permission from FastAPI
                                          await ref.read(chatRepositoryProvider).requestChat(user.userId);
                                          // In a real app we'd get the roomId back and navigate. 
                                          // For now, let's just show a snackbar or navigate to inbox.
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Chat request sent! Check your inbox.')),
                                            );
                                          }
                                        } catch (e) {"""

new_request = """                                        try {
                                          final currentUser = ref.read(currentUserProvider);
                                          final isMutual = currentUser != null && 
                                              currentUser.followingList.contains(user.userId) && 
                                              currentUser.followersList.contains(user.userId);

                                          await ref.read(chatRepositoryProvider).requestChat(user.userId, isMutual: isMutual);
                                          
                                          if (context.mounted) {
                                            if (isMutual) {
                                              // Direct chat if mutual
                                              final uids = [currentUser!.userId, user.userId]..sort();
                                              final roomId = 'chat_${uids[0]}_${uids[1]}';
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ChatRoomScreen(
                                                    roomId: roomId,
                                                    roomType: 'peer',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Message request sent!')),
                                              );
                                            }
                                          }
                                        } catch (e) {"""

content = content.replace(old_request, new_request)
with open('lib/features/profile/presentation/screens/public_profile_screen.dart', 'w') as f:
    f.write(content)
