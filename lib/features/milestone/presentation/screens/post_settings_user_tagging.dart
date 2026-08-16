import 'package:healing_milestones/shared/widgets/app_loader.dart';
part of 'post_settings_screen.dart';

extension PostSettingsUserTagging on _PostSettingsScreenState {
  Widget _buildUserTaggingSection(BuildContext context, ThemeData theme) {
    return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tag People & Medical Professionals',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Selected Users Chips
                  if (_selectedUsers.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedUsers.map((u) {
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              u.profilePicture ??
                                  'https://api.dicebear.com/7.x/avataaars/png?seed=${u.userId}', maxHeight: 200),
                          ),
                          label: Text(
                            '@${u.username ?? u.displayName}',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.primary.computeLuminance() >
                                      0.25
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: theme.primaryColor,
                          deleteIconColor:
                              theme.colorScheme.primary.computeLuminance() >
                                  0.25
                              ? Colors.black
                              : Colors.white,
                          onDeleted: () {
                            setState(() {
                              _selectedUsers.removeWhere(
                                (selected) => selected.userId == u.userId,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // User Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _userSearchController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search people to tag...',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.54),
                          size: 20,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                        ),
                        suffixIcon: _isSearchingUsers
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: const AppLoader.small(),
                                ),
                              )
                            : null,
                      ),
                      onChanged: _onUserSearchChanged,
                    ),
                  ),
                  // User Suggestions Dropdown
                  if (_userSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        children: _userSuggestions.map((u) {
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundImage: CachedNetworkImageProvider(
                                  u.profilePicture ??
                                      'https://api.dicebear.com/7.x/avataaars/png?seed=${u.userId}', maxHeight: 200),
                              ),
                              title: Text(
                                u.displayName,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: u.username != null
                                  ? Text(
                                      '@${u.username}',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                _addUser(u);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
  }
}