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
  EmergencyRegionOption(
      region: 'India / EU (Unified)', code: 'IN / EU', number: '112'),
  EmergencyRegionOption(
      region: 'India (Ambulance)', code: 'IN', number: '108'),
  EmergencyRegionOption(
      region: 'United States & Canada', code: 'US / CA', number: '911'),
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

  (String, String) _detectLocaleDefault() {
    final country =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode?.toUpperCase();
    switch (country) {
      case 'US':
      case 'CA':
        return ('911', 'US / CA');
      case 'GB':
      case 'UK':
        return ('999', 'UK');
      case 'AU':
        return ('000', 'AU');
      default:
        return ('112', 'IN / EU');
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final (defaultNum, defaultRegion) = _detectLocaleDefault();
    final savedNumber = prefs.getString(_keyEmergencyNumber) ?? defaultNum;
    final savedRegion = prefs.getString(_keyEmergencyRegion) ?? defaultRegion;
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

void showEmergencySosSheet(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;
  final customController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) {
      return Consumer(
        builder: (ctx, sheetRef, _) {
          final state = sheetRef.watch(awarenessProvider);
          final isHi = state.language == AwarenessLanguage.hi;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Primary Call CTA (prevents accidental 1-tap dialing)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      launchEmergencyDialer(context, state.emergencyNumber);
                    },
                    icon: const Icon(Icons.call_rounded, size: 20),
                    label: Text(
                      isHi
                          ? 'अभी ${state.emergencyNumber} पर कॉल करें'
                          : 'Call ${state.emergencyNumber} Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isHi
                      ? 'क्षेत्र या नंबर बदलें'
                      : 'Switch Emergency Number',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...emergencyRegions.map((opt) {
                  final selected = state.emergencyNumber == opt.number &&
                      state.emergencyRegionCode == opt.code;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        sheetRef
                            .read(awarenessProvider.notifier)
                            .setEmergencyRegion(opt.number, opt.code);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? primary.withValues(alpha: 0.12)
                              : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? primary : theme.dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              opt.number,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt.region,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle,
                                  color: primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: isHi
                              ? 'या कस्टम नंबर दर्ज करें...'
                              : 'Or enter custom number...',
                          isDense: true,
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: () {
                        final num = customController.text.trim();
                        if (num.isNotEmpty) {
                          sheetRef
                              .read(awarenessProvider.notifier)
                              .setEmergencyRegion(num, 'CUSTOM');
                          customController.clear();
                        }
                      },
                      child: Text(isHi ? 'सहेजें' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
