import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/medical_vault_models.dart';
import '../../data/repositories/medical_vault_repository.dart';

part 'medical_vault_providers.g.dart';

@riverpod
class MedicalRecordsNotifier extends _$MedicalRecordsNotifier {
  @override
  FutureOr<List<MedicalRecord>> build() {
    return ref.watch(medicalVaultRepositoryProvider).getMedicalRecords();
  }

  Future<void> uploadReport({
    required File file,
    required String fileName,
    required String title,
    required DateTime encounterDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newRecord = await ref.read(medicalVaultRepositoryProvider).uploadReport(
        file: file,
        fileName: fileName,
        title: title,
        encounterDate: encounterDate,
      );
      final currentList = state.value ?? [];
      return [newRecord, ...currentList];
    });
  }

  Future<void> deleteReport(String id) async {
    await ref.read(medicalVaultRepositoryProvider).deleteReport(id);
    if (state.hasValue) {
      state = AsyncData(state.value!.where((r) => r.id != id).toList());
    }
  }
}

@riverpod
class MixViewsNotifier extends _$MixViewsNotifier {
  @override
  FutureOr<List<MixView>> build() {
    return ref.watch(medicalVaultRepositoryProvider).getMixViews();
  }

  Future<MixView> createMixView({
    required String name,
    required String journeyId,
    required List<String> selectedReportIds,
    required int durationHours,
  }) async {
    final newView = await ref.read(medicalVaultRepositoryProvider).createMixView(
      name: name,
      journeyId: journeyId,
      selectedReportIds: selectedReportIds,
      durationHours: durationHours,
    );
    
    if (state.hasValue) {
      state = AsyncData([newView, ...state.value!]);
    }
    return newView;
  }

  Future<void> revokeMixView(String id) async {
    await ref.read(medicalVaultRepositoryProvider).revokeMixView(id);
    if (state.hasValue) {
      state = AsyncData(state.value!.where((v) => v.id != id).toList());
    }
  }
}
