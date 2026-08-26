import re

def patch(filepath, old_str, new_str):
    with open(filepath, "r") as f:
        content = f.read()
    content = content.replace(old_str, new_str)
    with open(filepath, "w") as f:
        f.write(content)

patch("lib/features/journey/presentation/widgets/log_milestone_overlay.dart",
"""  Color _getEmotionColor(EmotionStatus status) {
    switch (status.category) {
      case EmotionCategory.positive:
        return Colors.orange;
      case EmotionCategory.negative:
        return Colors.deepPurple;
      case EmotionCategory.neutral:
      default:
        return Colors.grey;
    }
  }""",
"""  Color _getEmotionColor(EmotionStatus status) {
    return status.category.color;
  }""")

patch("lib/features/journey/presentation/widgets/timeline_node.dart",
"""  Color _getEmotionColor(BuildContext context, EmotionStatus status) {
    switch (status.category) {
      case EmotionCategory.positive:
        return Colors.orange;
      case EmotionCategory.negative:
        return Colors.deepPurple;
      case EmotionCategory.neutral:
      default:
        return Colors.grey;
    }
  }""",
"""  Color _getEmotionColor(BuildContext context, EmotionStatus status) {
    return status.category.color;
  }""")

patch("lib/features/journey/presentation/widgets/together_feed_card.dart",
"""  Color _getEmotionColor() {
    switch (widget.milestone.emotionStatus?.category) {
      case EmotionCategory.positive:
        return Colors.orange;
      case EmotionCategory.negative:
        return Colors.deepPurple;
      case EmotionCategory.neutral:
      default:
        return Colors.grey;
    }
  }""",
"""  Color _getEmotionColor() {
    return widget.milestone.emotionStatus?.category.color ?? Colors.grey;
  }""")

patch("lib/features/journey/presentation/widgets/together_feed_card.dart",
"""      switch (widget.milestone.emotionStatus?.category) {
        case EmotionCategory.positive:
          emotionColor = Colors.green;
          break;
        case EmotionCategory.negative:
          emotionColor = Colors.purple;
          break;
        case EmotionCategory.neutral:
        default:
          emotionColor = Colors.grey;
          break;
      }""",
"""      emotionColor = widget.milestone.emotionStatus?.category.color ?? Colors.grey;""")

