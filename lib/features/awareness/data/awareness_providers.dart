import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum AwarenessLanguage {
  en,
  hi,
}

enum ScienceDepth {
  simple,
  clinical,
}

extension AwarenessLanguageX on AwarenessLanguage {
  String get code => this == AwarenessLanguage.hi ? 'hi' : 'en';
  String get label => this == AwarenessLanguage.hi ? 'हिन्दी' : 'English';
  String get shortLabel => this == AwarenessLanguage.hi ? 'हिं' : 'EN';
  String get ttsLocale => this == AwarenessLanguage.hi ? 'hi-IN' : 'en-US';
}

class EmergencyRegionOption {
  final String region;
  final String code;
  final String number;

  const EmergencyRegionOption({
    required this.region,
    required this.code,
    required this.number,
  });
}

const List<EmergencyRegionOption> emergencyRegions = [
  EmergencyRegionOption(region: 'India / EU (Unified)', code: 'IN / EU', number: '112'),
  EmergencyRegionOption(region: 'India (Ambulance)', code: 'IN', number: '108'),
  EmergencyRegionOption(region: 'United States & Canada', code: 'US / CA', number: '911'),
  EmergencyRegionOption(region: 'United Kingdom', code: 'UK', number: '999'),
  EmergencyRegionOption(region: 'Australia', code: 'AU', number: '000'),
];

class AwarenessState {
  final String emergencyNumber;
  final String emergencyRegionCode;
  final Set<String> completedGuideIds;
  final AwarenessLanguage language;
  final ScienceDepth scienceDepth;

  const AwarenessState({
    this.emergencyNumber = '112',
    this.emergencyRegionCode = 'IN / EU',
    this.completedGuideIds = const {},
    this.language = AwarenessLanguage.en,
    this.scienceDepth = ScienceDepth.simple,
  });

  AwarenessState copyWith({
    String? emergencyNumber,
    String? emergencyRegionCode,
    Set<String>? completedGuideIds,
    AwarenessLanguage? language,
    ScienceDepth? scienceDepth,
  }) {
    return AwarenessState(
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      emergencyRegionCode: emergencyRegionCode ?? this.emergencyRegionCode,
      completedGuideIds: completedGuideIds ?? this.completedGuideIds,
      language: language ?? this.language,
      scienceDepth: scienceDepth ?? this.scienceDepth,
    );
  }
}

class AwarenessNotifier extends Notifier<AwarenessState> {
  static const _keyEmergencyNumber = 'awareness_emergency_number';
  static const _keyEmergencyRegion = 'awareness_emergency_region';
  static const _keyCompletedGuides = 'awareness_completed_guides';
  static const _keyLanguage = 'awareness_language';
  static const _keyScienceDepth = 'awareness_science_depth';

  @override
  AwarenessState build() {
    _loadFromPrefs();
    return const AwarenessState();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNumber = prefs.getString(_keyEmergencyNumber) ?? '112';
    final savedRegion = prefs.getString(_keyEmergencyRegion) ?? 'IN / EU';
    final savedGuides = prefs.getStringList(_keyCompletedGuides) ?? [];
    final savedLang = prefs.getString(_keyLanguage) ?? 'en';
    final savedDepth = prefs.getString(_keyScienceDepth) ?? 'simple';
    state = state.copyWith(
      emergencyNumber: savedNumber,
      emergencyRegionCode: savedRegion,
      completedGuideIds: savedGuides.toSet(),
      language: savedLang == 'hi' ? AwarenessLanguage.hi : AwarenessLanguage.en,
      scienceDepth:
          savedDepth == 'clinical' ? ScienceDepth.clinical : ScienceDepth.simple,
    );
  }

  Future<void> setEmergencyRegion(String number, String regionCode) async {
    state = state.copyWith(
      emergencyNumber: number,
      emergencyRegionCode: regionCode,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmergencyNumber, number);
    await prefs.setString(_keyEmergencyRegion, regionCode);
  }

  Future<void> setLanguage(AwarenessLanguage lang) async {
    state = state.copyWith(language: lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang.code);
  }

  Future<void> setScienceDepth(ScienceDepth depth) async {
    state = state.copyWith(scienceDepth: depth);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyScienceDepth,
      depth == ScienceDepth.clinical ? 'clinical' : 'simple',
    );
  }

  Future<void> markGuideCompleted(String guideId) async {
    if (state.completedGuideIds.contains(guideId)) return;
    final updated = {...state.completedGuideIds, guideId};
    state = state.copyWith(completedGuideIds: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedGuides, updated.toList());
  }
}

final awarenessProvider =
    NotifierProvider<AwarenessNotifier, AwarenessState>(() {
  return AwarenessNotifier();
});

Future<void> launchEmergencyDialer(BuildContext context, String number) async {
  final uri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dial $number immediately from your phone app.'),
      ),
    );
  }
}
