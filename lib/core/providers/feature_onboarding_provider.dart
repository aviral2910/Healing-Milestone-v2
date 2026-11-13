import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../../features/auth/data/auth_provider.dart';

class FeatureOnboardingState {
  final bool hasSeenMedicalVault;
  final bool hasSeenHealthSnapshot;

  const FeatureOnboardingState({
    required this.hasSeenMedicalVault,
    required this.hasSeenHealthSnapshot,
  });

  FeatureOnboardingState copyWith({
    bool? hasSeenMedicalVault,
    bool? hasSeenHealthSnapshot,
  }) {
    return FeatureOnboardingState(
      hasSeenMedicalVault: hasSeenMedicalVault ?? this.hasSeenMedicalVault,
      hasSeenHealthSnapshot:
          hasSeenHealthSnapshot ?? this.hasSeenHealthSnapshot,
    );
  }
}

class FeatureOnboardingNotifier extends Notifier<FeatureOnboardingState> {
  static const String _vaultKeyPrefix = 'has_seen_medical_vault_onboarding';
  static const String _snapshotKeyPrefix =
      'has_seen_health_snapshot_onboarding';

  String _scopedKey(String prefix, String? userId) {
    return userId != null && userId.isNotEmpty ? '${prefix}_$userId' : prefix;
  }

  @override
  FeatureOnboardingState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final userId = ref.watch(currentUserProvider.select((u) => u?.userId));

    return FeatureOnboardingState(
      hasSeenMedicalVault:
          prefs.getBool(_scopedKey(_vaultKeyPrefix, userId)) ?? false,
      hasSeenHealthSnapshot:
          prefs.getBool(_scopedKey(_snapshotKeyPrefix, userId)) ?? false,
    );
  }

  Future<void> markMedicalVaultSeen() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final userId = ref.read(currentUserProvider)?.userId;
    await prefs.setBool(_scopedKey(_vaultKeyPrefix, userId), true);
    state = state.copyWith(hasSeenMedicalVault: true);
  }

  Future<void> markHealthSnapshotSeen() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final userId = ref.read(currentUserProvider)?.userId;
    await prefs.setBool(_scopedKey(_snapshotKeyPrefix, userId), true);
    state = state.copyWith(hasSeenHealthSnapshot: true);
  }
}

final featureOnboardingProvider =
    NotifierProvider<FeatureOnboardingNotifier, FeatureOnboardingState>(
      FeatureOnboardingNotifier.new,
    );
