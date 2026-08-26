import re

with open('lib/features/profile/presentation/screens/public_profile_screen.dart', 'r') as f:
    content = f.read()

old_logic = """                                          if (context.mounted) {
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
                                          }"""

new_logic = """                                          if (context.mounted) {
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
                                          }"""

content = content.replace(old_logic, new_logic)
with open('lib/features/profile/presentation/screens/public_profile_screen.dart', 'w') as f:
    f.write(content)
