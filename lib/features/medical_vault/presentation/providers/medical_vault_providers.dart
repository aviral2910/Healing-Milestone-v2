import 'package:file_picker/file_picker.dart';

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
    required List<PlatformFile> files,
    required List<String> reportTypes,
    required DateTime encounterDate,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newRecord = await ref.read(medicalVaultRepositoryProvider).uploadReport(
        files: files,
        reportTypes: reportTypes,
        encounterDate: encounterDate,
      );
      final currentList = state.value ?? [];
      return [newRecord, ...currentList];
    });
  }

  Future<void> updateReport({
    required String id,
    required List<String> reportTypes,
    required DateTime encounterDate,
    required List<MedicalRecordFile> existingFiles,
    required List<PlatformFile> newFiles,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(medicalVaultRepositoryProvider);
      
      List<MedicalRecordFile> uploadedFiles = [];
      if (newFiles.isNotEmpty) {
        uploadedFiles = await repo.uploadFiles(newFiles);
      }
      final combinedFiles = [...existingFiles, ...uploadedFiles];

      final updatedRecord = await repo.updateReport(
        id: id,
        reportTypes: reportTypes,
        encounterDate: encounterDate,
        files: combinedFiles,
      );
      final currentList = state.value ?? [];
      return currentList.map((r) => r.id == id ? updatedRecord : r).toList();
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
