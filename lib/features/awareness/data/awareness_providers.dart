import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  const AwarenessState({
    this.emergencyNumber = '112',
    this.emergencyRegionCode = 'IN / EU',
    this.completedGuideIds = const {},
  });

  AwarenessState copyWith({
    String? emergencyNumber,
    String? emergencyRegionCode,
    Set<String>? completedGuideIds,
  }) {
    return AwarenessState(
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      emergencyRegionCode: emergencyRegionCode ?? this.emergencyRegionCode,
      completedGuideIds: completedGuideIds ?? this.completedGuideIds,
    );
  }
}

class AwarenessNotifier extends Notifier<AwarenessState> {
  static const _keyEmergencyNumber = 'awareness_emergency_number';
  static const _keyEmergencyRegion = 'awareness_emergency_region';
  static const _keyCompletedGuides = 'awareness_completed_guides';

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
    state = state.copyWith(
      emergencyNumber: savedNumber,
      emergencyRegionCode: savedRegion,
      completedGuideIds: savedGuides.toSet(),
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
