import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/biomarker_model.dart';
import 'medical_vault_providers.dart';
import '../../data/repositories/medical_vault_repository.dart';

part 'trends_provider.g.dart';

@riverpod
class BiomarkerTrends extends _$BiomarkerTrends {
  @override
  Future<List<BiomarkerTrendModel>> build() async {
    final repository = ref.watch(medicalVaultRepositoryProvider);
    return await repository.getBiomarkerTrends();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(medicalVaultRepositoryProvider).getBiomarkerTrends());
  }
}
