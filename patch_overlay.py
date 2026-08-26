import re

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "r") as f:
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

old_icon = """  IconData _getEmotionIcon(EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud:
        return Icons.emoji_events_rounded;
      case EmotionStatus.hopeful:
        return Icons.wb_sunny_rounded;
      case EmotionStatus.anxious:
        return Icons.waves_rounded;
      case EmotionStatus.grieving:
        return Icons.opacity_rounded;
      case EmotionStatus.neutral:
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }"""

new_icon = """  IconData _getEmotionIcon(EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud: return Icons.emoji_events_rounded;
      case EmotionStatus.hopeful: return Icons.wb_sunny_rounded;
      case EmotionStatus.relieved: return Icons.air_rounded;
      case EmotionStatus.grateful: return Icons.favorite_rounded;
      case EmotionStatus.determined: return Icons.local_fire_department_rounded;
      case EmotionStatus.anxious: return Icons.waves_rounded;
      case EmotionStatus.grieving: return Icons.opacity_rounded;
      case EmotionStatus.exhausted: return Icons.battery_0_bar_rounded;
      case EmotionStatus.frustrated: return Icons.storm_rounded;
      case EmotionStatus.overwhelmed: return Icons.tsunami_rounded;
      case EmotionStatus.isolated: return Icons.person_off_rounded;
      case EmotionStatus.neutral: return Icons.sentiment_neutral_rounded;
      case EmotionStatus.reflective: return Icons.lightbulb_rounded;
      case EmotionStatus.waiting: return Icons.hourglass_empty_rounded;
      default: return Icons.sentiment_neutral_rounded;
    }
  }"""

old_label = """  String _getEmotionLabel(EmotionStatus status) {
    switch (status) {
      case EmotionStatus.proud:
        return 'Proud';
      case EmotionStatus.hopeful:
        return 'Hopeful';
      case EmotionStatus.anxious:
        return 'Anxious';
      case EmotionStatus.grieving:
        return 'Grieving';
      case EmotionStatus.neutral:
      default:
        return 'Okay';
    }
  }"""

new_label = """  String _getEmotionLabel(EmotionStatus status) {
    return status.displayName;
  }"""

content = content.replace(old_color, new_color)
content = content.replace(old_icon, new_icon)
content = content.replace(old_label, new_label)

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "w") as f:
    f.write(content)
