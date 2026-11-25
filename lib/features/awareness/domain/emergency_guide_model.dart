import 'package:flutter/material.dart';

enum EmergencyCategory {
  cardiac,
  breathing,
  bleeding,
  neurological,
  burns,
  allergy,
}

extension EmergencyCategoryX on EmergencyCategory {
  String get label {
    switch (this) {
      case EmergencyCategory.cardiac:
        return 'Cardiac & CPR';
      case EmergencyCategory.breathing:
        return 'Airway & Choking';
      case EmergencyCategory.bleeding:
        return 'Bleeding & Trauma';
      case EmergencyCategory.neurological:
        return 'Stroke & Seizures';
      case EmergencyCategory.burns:
        return 'Burns & Scalds';
      case EmergencyCategory.allergy:
        return 'Allergies';
    }
  }

  IconData get icon {
    switch (this) {
      case EmergencyCategory.cardiac:
        return Icons.favorite_rounded;
      case EmergencyCategory.breathing:
        return Icons.air_rounded;
      case EmergencyCategory.bleeding:
        return Icons.bloodtype_rounded;
      case EmergencyCategory.neurological:
        return Icons.psychology_rounded;
      case EmergencyCategory.burns:
        return Icons.local_fire_department_rounded;
      case EmergencyCategory.allergy:
        return Icons.medical_services_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case EmergencyCategory.cardiac:
        return const Color(0xFFE53935);
      case EmergencyCategory.breathing:
        return const Color(0xFF00ACC1);
      case EmergencyCategory.bleeding:
        return const Color(0xFFD81B60);
      case EmergencyCategory.neurological:
        return const Color(0xFF8E24AA);
      case EmergencyCategory.burns:
        return const Color(0xFFFB8C00);
      case EmergencyCategory.allergy:
        return const Color(0xFF43A047);
    }
  }
}

class EmergencyStep {
  final int stepNumber;
  final String title;
  final String instruction;
  final String voicePrompt;
  final String? criticalNote;

  const EmergencyStep({
    required this.stepNumber,
    required this.title,
    required this.instruction,
    required this.voicePrompt,
    this.criticalNote,
  });
}

class EmergencyQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const EmergencyQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class EmergencyGuide {
  final String id;
  final String title;
  final String subtitle;
  final EmergencyCategory category;
  final bool isCritical;
  final bool hasMetronome;
  final int estimatedReadMinutes;
  final String whenToCallEmergency;
  final List<EmergencyStep> steps;
  final List<String> doNots;
  final List<EmergencyQuizQuestion> quizzes;

  const EmergencyGuide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.isCritical = false,
    this.hasMetronome = false,
    this.estimatedReadMinutes = 2,
    required this.whenToCallEmergency,
    required this.steps,
    required this.doNots,
    required this.quizzes,
  });
}
