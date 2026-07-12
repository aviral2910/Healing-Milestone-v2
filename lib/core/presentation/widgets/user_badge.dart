import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class UserBadge extends StatelessWidget {
  final UserRole role;
  final bool isVerified;
  final double iconSize;

  const UserBadge({
    super.key,
    required this.role,
    this.isVerified = false,
    this.iconSize = 16.0,
  });

  Widget _buildShinyBadge(IconData innerIcon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. The outer verified starburst shape
        Icon(
          Icons.verified,
          color: const Color(0xFFFFD700), // Golden color
          size: iconSize + 4,
          shadows: [
            Shadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        // 2. A gold circle to cover the transparent checkmark hole in the middle
        Icon(
          Icons.circle,
          color: const Color(0xFFFFD700),
          size: iconSize - 2, 
        ),
        // 3. The actual role icon, colored to look like it's cut out (background color)
        Icon(
          innerIcon,
          color: const Color(0xFF151515), // App background color
          size: iconSize - 4, // Smaller to fit inside
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> badges = [];

    // Verified Status
    // Don't show the verified tick for roles that inherently imply verification
    bool showVerifiedTick = isVerified && 
        role != UserRole.healthcareProfessional && 
        role != UserRole.organization;

    if (showVerifiedTick) {
      badges.add(
        Icon(
          Icons.verified,
          color: const Color(0xFFFFD700), // Golden color for verified
          size: iconSize + 2,
          shadows: [
            Shadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
      );
    }

    // Role-specific Badges
    Widget? roleBadge;
    switch (role) {
      case UserRole.healthcareProfessional:
        roleBadge = _buildShinyBadge(Icons.medical_services);
        break;
      case UserRole.organization:
        roleBadge = _buildShinyBadge(Icons.domain);
        break;
      case UserRole.reviewer:
        roleBadge = _buildShinyBadge(Icons.shield);
        break;
      case UserRole.author:
      case UserRole.reader:
        // No additional role badge by default
        break;
    }

    if (roleBadge != null) {
      if (badges.isNotEmpty) {
        badges.add(const SizedBox(width: 6));
      }
      badges.add(roleBadge);
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: badges,
    );
  }
}
