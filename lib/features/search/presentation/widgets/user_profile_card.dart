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
    final isProOrOrg = user.role == UserRole.healthcareProfessional ||
        user.role == UserRole.organization;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF2A2A2A),
              backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      UserBadge(
                        role: user.role,
                        isVerified: user.isVerified,
                        iconSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: Color(0xFFA1A1A6),
                      fontSize: 14,
                    ),
                  ),
                  if (isProOrOrg) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.role == UserRole.healthcareProfessional
                          ? 'Healthcare Professional'
                          : 'Organization',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}
