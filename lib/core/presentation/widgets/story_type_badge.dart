import 'package:flutter/material.dart';
import '../../models/story_model.dart';

class StoryTypeBadge extends StatelessWidget {
  final StoryType type;

  const StoryTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == StoryType.story) return const SizedBox.shrink();

    String label = type.name.toUpperCase();
    Color color;
    IconData icon;

    switch (type) {
      case StoryType.finding:
        color = const Color(0xFF4A90E2); // Blue
        icon = Icons.science;
        break;
      case StoryType.awareness:
        color = const Color(0xFFE24A4A); // Red
        icon = Icons.campaign;
        break;
      case StoryType.journey:
        color = const Color(0xFF9B4AE2); // Purple
        icon = Icons.route;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
