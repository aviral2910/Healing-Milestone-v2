import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_vault_models.freezed.dart';
part 'medical_vault_models.g.dart';

@freezed
abstract class MedicalRecordFile with _$MedicalRecordFile {
  const factory MedicalRecordFile({
    required String url,
    required String fileType,
    required String fileName,
  }) = _MedicalRecordFile;

  factory MedicalRecordFile.fromJson(Map<String, dynamic> json) => _$MedicalRecordFileFromJson(json);
}

@freezed
abstract class MedicalRecord with _$MedicalRecord {
  const factory MedicalRecord({
    required String id,
    required String userId,
    required DateTime encounterDate,
    required List<String> reportTypes,
    required List<MedicalRecordFile> files,
    required DateTime createdAt,
  }) = _MedicalRecord;

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => _$MedicalRecordFromJson(json);
}

@freezed
abstract class MixView with _$MixView {
  const factory MixView({
    required String id,
    required String userId,
    required String name,
    required List<String> journeyIds,
    required List<String> selectedReportIds,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) = _MixView;

  factory MixView.fromJson(Map<String, dynamic> json) => _$MixViewFromJson(json);
}
