with open("lib/features/journey/data/models/journey_models.dart", "r") as f:
    content = f.read()

old_enum = """enum EmotionStatus {
  @JsonValue('proud')
  proud,
  @JsonValue('anxious')
  anxious,
  @JsonValue('grieving')
  grieving,
  @JsonValue('hopeful')
  hopeful,
  @JsonValue('neutral')
  neutral;

  static EmotionStatus fromString(String value) {
    return EmotionStatus.values.firstWhere((e) => e.name == value, orElse: () => EmotionStatus.neutral);
  }
}"""

new_enum = """enum EmotionCategory {
  positive,
  negative, // Note: Rendered as "Challenging" or "Heavy" in UI
  neutral,
}

enum EmotionStatus {
  // Positive
  @JsonValue('proud')
  proud,
  @JsonValue('hopeful')
  hopeful,
  @JsonValue('relieved')
  relieved,
  @JsonValue('grateful')
  grateful,
  @JsonValue('determined')
  determined,

  // Negative / Challenging
  @JsonValue('anxious')
  anxious,
  @JsonValue('grieving')
  grieving,
  @JsonValue('exhausted')
  exhausted,
  @JsonValue('frustrated')
  frustrated,
  @JsonValue('overwhelmed')
  overwhelmed,
  @JsonValue('isolated')
  isolated,

  // Neutral
  @JsonValue('neutral')
  neutral,
  @JsonValue('reflective')
  reflective,
  @JsonValue('waiting')
  waiting;

  static EmotionStatus fromString(String value) {
    return EmotionStatus.values.firstWhere((e) => e.name == value, orElse: () => EmotionStatus.neutral);
  }
}

extension EmotionStatusExtension on EmotionStatus {
  EmotionCategory get category {
    switch (this) {
      case EmotionStatus.proud:
      case EmotionStatus.hopeful:
      case EmotionStatus.relieved:
      case EmotionStatus.grateful:
      case EmotionStatus.determined:
        return EmotionCategory.positive;
      case EmotionStatus.anxious:
      case EmotionStatus.grieving:
      case EmotionStatus.exhausted:
      case EmotionStatus.frustrated:
      case EmotionStatus.overwhelmed:
      case EmotionStatus.isolated:
        return EmotionCategory.negative;
      case EmotionStatus.neutral:
      case EmotionStatus.reflective:
      case EmotionStatus.waiting:
        return EmotionCategory.neutral;
    }
  }

  String get displayName {
    switch (this) {
      case EmotionStatus.proud: return 'Proud';
      case EmotionStatus.hopeful: return 'Hopeful';
      case EmotionStatus.relieved: return 'Relieved';
      case EmotionStatus.grateful: return 'Grateful';
      case EmotionStatus.determined: return 'Determined';
      
      case EmotionStatus.anxious: return 'Anxious';
      case EmotionStatus.grieving: return 'Grieving';
      case EmotionStatus.exhausted: return 'Exhausted';
      case EmotionStatus.frustrated: return 'Frustrated';
      case EmotionStatus.overwhelmed: return 'Overwhelmed';
      case EmotionStatus.isolated: return 'Isolated';
      
      case EmotionStatus.neutral: return 'Neutral';
      case EmotionStatus.reflective: return 'Reflective';
      case EmotionStatus.waiting: return 'Waiting';
    }
  }
}"""

content = content.replace(old_enum, new_enum)

with open("lib/features/journey/data/models/journey_models.dart", "w") as f:
    f.write(content)
