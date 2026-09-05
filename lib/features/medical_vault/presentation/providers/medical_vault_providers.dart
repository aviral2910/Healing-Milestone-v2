import 'package:file_picker/file_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/medical_vault_models.dart';
import '../../data/repositories/medical_vault_repository.dart';

part 'medical_vault_providers.g.dart';


@riverpod
Future<List<String>> uniqueMedicalTags(Ref ref) async {
  return await ref.watch(medicalVaultRepositoryProvider).getUniqueTags();
}

@riverpod
class MedicalRecordsNotifier extends _$MedicalRecordsNotifier {
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<MedicalRecord>> build() async {
    _hasMore = true;
    _isLoadingMore = false;
    final items = await ref.watch(medicalVaultRepositoryProvider).getMedicalRecords(skip: 0, limit: 20);
    if (items.length < 20) {
      _hasMore = false;
    }
    return items;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    final currentList = state.value;
    if (currentList == null) return;

    _isLoadingMore = true;
    // Tell listeners we are loading more without wiping out the existing data
    ref.notifyListeners(); 

    try {
      final newItems = await ref.read(medicalVaultRepositoryProvider).getMedicalRecords(
        skip: currentList.length, 
        limit: 20,
      );
      
      if (newItems.length < 20) {
        _hasMore = false;
      }
      
      state = AsyncData([...currentList, ...newItems]);
    } catch (e, st) {
      // Handle error gently
      print('Failed to load more records: $e');
    } finally {
      _isLoadingMore = false;
      ref.notifyListeners();
    }
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
    required List<String> journeyIds,
    required List<String> selectedReportIds,
    required int durationHours,
  }) async {
    final newView = await ref.read(medicalVaultRepositoryProvider).createMixView(
      name: name,
      journeyIds: journeyIds,
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
