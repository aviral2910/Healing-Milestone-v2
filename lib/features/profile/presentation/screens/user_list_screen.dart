import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/user_model.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../auth/data/repository_providers.dart';

class UserListScreen extends ConsumerStatefulWidget {
  final String title;
  final List<String> userIds;

  const UserListScreen({
    Key? key,
    required this.title,
    required this.userIds,
  }) : super(key: key);

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<UserModel> _users = [];
  bool _isLoading = false;
  int _currentOffset = 0;
  final int _chunkSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMoreUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoading || _currentOffset >= widget.userIds.length) return;

    setState(() {
      _isLoading = true;
    });

    final endIndex = (_currentOffset + _chunkSize > widget.userIds.length)
        ? widget.userIds.length
        : _currentOffset + _chunkSize;
        
    final chunk = widget.userIds.sublist(_currentOffset, endIndex);
    
    final repo = ref.read(userRepositoryProvider);
    final usersChunk = await repo.getUsersByIds(chunk);

    if (mounted) {
      setState(() {
        _users.addAll(usersChunk);
        _currentOffset = endIndex;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: widget.userIds.isEmpty
          ? Center(
              child: Text(
                'No users yet.',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _users.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _users.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(color: theme.primaryColor),
                    ),
                  );
                }

                final user = _users[index];
                final isFollowing = currentUser?.followingList.contains(user.userId) ?? false;
                final isCurrentUser = currentUser?.userId == user.userId;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(
                      user.profilePicture ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}',
                    ),
                  ),
                  title: Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: user.username != null && user.username!.isNotEmpty
                      ? Text('@${user.username}')
                      : null,
                  trailing: isCurrentUser
                      ? null
                      : ElevatedButton(
                          onPressed: () {
                            if (currentUser == null) {
                              context.push(AppRoutes.login);
                            } else {
                              ref.read(userRepositoryProvider).toggleFollow(currentUser.userId, user.userId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Theme.of(context).dividerColor : theme.colorScheme.primary,
                            foregroundColor: isFollowing ? theme.textTheme.bodyMedium?.color : (theme.colorScheme.primary.computeLuminance() > 0.25 ? Colors.black : Colors.white),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                  onTap: () {
                    if (isCurrentUser) {
                      context.push(AppRoutes.profile);
                    } else {
                      context.push(AppRoutes.publicProfile(user.userId));
                    }
                  },
                );
              },
            ),
    );
  }
}
