import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final dynamic role;
  final bool isAnonymous;
  final bool showRing;
  final Color? ringColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    this.role,
    this.isAnonymous = false,
    this.showRing = false,
    this.ringColor,
  });

  bool get _isProfessional {
    if (role == null) return false;
    final r = role.toString().toLowerCase();
    return r.contains('healthcareprofessional') || r.contains('organi');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final defaultRingColor = ringColor ?? primary.withValues(alpha: 0.5);

    final bool professional = _isProfessional;

    final shape = professional ? BoxShape.rectangle : BoxShape.circle;
    final outerRadius = professional
        ? BorderRadius.circular(radius * 0.6)
        : null;
    final innerRadius = professional
        ? BorderRadius.circular(radius * 0.45)
        : null;

    Widget avatarContent = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: innerRadius,
        color: isAnonymous
            ? primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        image: (imageUrl != null && !isAnonymous)
            ? DecorationImage(
                image: CachedNetworkImageProvider(
                  imageUrl!,
                  maxHeight: (radius * 3).toInt(),
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: (imageUrl == null || isAnonymous)
          ? Icon(
              isAnonymous
                  ? Icons.visibility_off_rounded
                  : (professional
                        ? Icons.domain_rounded
                        : Icons.person_rounded),
              color: isAnonymous ? primary : theme.colorScheme.onSurfaceVariant,
              size: radius * 1.1,
            )
          : null,
    );

    if (showRing) {
      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: outerRadius,
          border: Border.all(color: defaultRingColor, width: 1.5),
        ),
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}
