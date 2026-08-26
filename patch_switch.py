import os

def replace_in_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # We want to replace the switch block in `together_feed_card.dart`
    # Let's just use regex or simple string replacement.
    
    old_switch = """    switch (widget.milestone.emotionStatus) {
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
    }"""
    
    new_switch = """    switch (widget.milestone.emotionStatus?.category) {
      case EmotionCategory.positive:
        return Colors.orange;
      case EmotionCategory.negative:
        return Colors.deepPurple;
      case EmotionCategory.neutral:
      default:
        return Colors.grey;
    }"""
    
    content = content.replace(old_switch, new_switch)
    
    old_switch_2 = """      switch (widget.milestone.emotionStatus) {
        case EmotionStatus.proud:
          emotionColor = Colors.orange;
          break;
        case EmotionStatus.hopeful:
          emotionColor = Colors.green;
          break;
        case EmotionStatus.anxious:
          emotionColor = Colors.purple;
          break;
        case EmotionStatus.grieving:
          emotionColor = Colors.blueGrey;
          break;
        case EmotionStatus.neutral:
        default:
          emotionColor = Colors.grey;
          break;
      }"""
      
    new_switch_2 = """      switch (widget.milestone.emotionStatus?.category) {
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
      }"""
      
    content = content.replace(old_switch_2, new_switch_2)

    with open(filepath, "w") as f:
        f.write(content)

replace_in_file("lib/features/journey/presentation/widgets/together_feed_card.dart")
