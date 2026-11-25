import 'package:flutter/material.dart';
import 'awareness_providers.dart';

class ReadinessBadge {
  final String id;
  final IconData icon;
  final List<String> guideIds;
  final String titleEn;
  final String titleHi;

  const ReadinessBadge({
    required this.id,
    required this.icon,
    required this.guideIds,
    required this.titleEn,
    required this.titleHi,
  });

  String title(AwarenessLanguage lang) =>
      lang == AwarenessLanguage.hi ? titleHi : titleEn;

  int completedCount(Set<String> completedIds) =>
      guideIds.where(completedIds.contains).length;

  bool isUnlocked(Set<String> completedIds) =>
      completedCount(completedIds) == guideIds.length;
}

const List<ReadinessBadge> readinessBadges = [
  ReadinessBadge(
    id: 'heart_saver',
    icon: Icons.favorite_rounded,
    guideIds: ['cpr_adult', 'heart_attack_signs'],
    titleEn: 'Heart Saver',
    titleHi: 'हृदय रक्षक',
  ),
  ReadinessBadge(
    id: 'airway_guardian',
    icon: Icons.air_rounded,
    guideIds: ['choking_adult', 'infant_choking_cpr', 'asthma_attack'],
    titleEn: 'Airway Guardian',
    titleHi: 'श्वसन रक्षक',
  ),
  ReadinessBadge(
    id: 'trauma_ready',
    icon: Icons.healing_rounded,
    guideIds: ['severe_bleeding', 'burns_scalds', 'snake_bite', 'spinal_injury'],
    titleEn: 'Trauma Ready',
    titleHi: 'चोट एवं आघात',
  ),
  ReadinessBadge(
    id: 'rapid_responder',
    icon: Icons.bolt_rounded,
    guideIds: [
      'stroke_fast',
      'seizures_fainting',
      'anaphylaxis',
      'diabetic_hypoglycemia',
    ],
    titleEn: 'Rapid Responder',
    titleHi: 'त्वरित सहायक',
  ),
];

String getReadinessTier(
  int completed,
  int total,
  AwarenessLanguage lang,
) {
  final isHi = lang == AwarenessLanguage.hi;
  if (total > 0 && completed >= total) {
    return isHi ? 'कम्युनिटी रिस्पॉन्डर' : 'Community Responder';
  }
  if (completed >= 9) {
    return isHi ? 'प्राथमिक चिकित्सा तैयार' : 'First-Aid Ready';
  }
  if (completed >= 4) {
    return isHi ? 'सजग मददगार' : 'Prepared Bystander';
  }
  return isHi ? 'शुरुआती स्तर' : 'Getting Started';
}
