import re

with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

old_search_bar = """            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search people...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),"""

new_search_bar = """            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Text(
              "Send to",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),"""
content = content.replace(old_search_bar, new_search_bar)

old_grid_params = """                            crossAxisCount: 4,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.65, 
                          ),"""
new_grid_params = """                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.75, 
                          ),"""
content = content.replace(old_grid_params, new_grid_params)

old_avatar = "AppAvatar(imageUrl: user.profilePicture, radius: 34)"
new_avatar = "AppAvatar(imageUrl: user.profilePicture, radius: 28)"
content = content.replace(old_avatar, new_avatar)

old_name = """                                      Text(
                                        user.displayName.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontSize: 13,"""
new_name = """                                      Text(
                                        user.displayName.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontSize: 11,"""
content = content.replace(old_name, new_name)


old_send_btn = """            // Big Send Button (only visible when items selected)
            if (_selectedUserIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: activeChatsAsync.whenOrNull(
                  data: (rooms) => ElevatedButton(
                    onPressed: _isSending ? null : () => _sendToSelected(rooms),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: _isSending
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                        : Text('Send', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                  ),
                ),
              ),
            ],

            Divider(height: 1, color: theme.dividerColor),"""

new_send_btn = """            // Big Send Button (only visible when items selected)
            if (_selectedUserIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: activeChatsAsync.whenOrNull(
                  data: (rooms) => ElevatedButton(
                    onPressed: _isSending ? null : () => _sendToSelected(rooms),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isSending
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                        : Text('Send', style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                  ),
                ),
              ),
            ],

            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),"""
content = content.replace(old_send_btn, new_send_btn)

old_options = """                  _buildOptionBtn(
                    context: context,
                    icon: Icons.link_rounded,
                    label: 'Copy Link',"""
new_options = """                  _buildOptionBtn(
                    context: context,
                    icon: Icons.link_rounded,
                    label: 'Copy link',"""
content = content.replace(old_options, new_options)

old_options2 = """                  _buildOptionBtn(
                    context: context,
                    icon: Icons.ios_share_rounded,
                    label: 'Share via',"""
new_options2 = """                  _buildOptionBtn(
                    context: context,
                    icon: Icons.ios_share_rounded,
                    label: 'Share to...',"""
content = content.replace(old_options2, new_options2)

old_btn_style = """  Widget _buildOptionBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final surfaceLight = theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(label, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13, color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }"""
new_btn_style = """  Widget _buildOptionBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final surfaceLight = theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 11, 
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }"""
content = content.replace(old_btn_style, new_btn_style)

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
