import re

with open("lib/features/journey/presentation/widgets/timeline_node.dart", "r") as f:
    content = f.read()

old_color = """  Color _getEmotionColor(EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud:
        return Colors.amber;
      case EmotionStatus.hopeful:
        return Colors.orange;
      case EmotionStatus.anxious:
        return Colors.blue;
      case EmotionStatus.grieving:
        return Colors.deepPurple;
      case EmotionStatus.neutral:
      default:
        return Colors.grey;
    }
  }"""

new_color = """  Color _getEmotionColor(EmotionStatus status) {
    switch (status.category) {
      case EmotionCategory.positive:
        return Colors.orange;
      case EmotionCategory.negative:
        return Colors.deepPurple;
      case EmotionCategory.neutral:
      default:
        return Colors.grey;
    }
  }"""

content = content.replace(old_color, new_color)

with open("lib/features/journey/presentation/widgets/timeline_node.dart", "w") as f:
    f.write(content)
