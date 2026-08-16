import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/presentation/widgets/user_badge.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserProfileCard({
    Key? key,
    required this.user,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).dividerColor,
              backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                  ? CachedNetworkImageProvider(user.profilePicture!, maxHeight: 200)
                  : null,
              child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            // Username (Golden) and Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700), // Golden color
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (user.role == UserRole.healthcareProfessional || user.isVerified) ...[
                  const SizedBox(width: 4),
                  UserBadge(
                    role: user.role,
                    isVerified: user.isVerified,
                    iconSize: 14,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // Display Name
            Text(
              user.displayName,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
