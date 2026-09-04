import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_vault_models.freezed.dart';
part 'medical_vault_models.g.dart';

@freezed
abstract class MedicalRecord with _$MedicalRecord {
  const factory MedicalRecord({
    required String id,
    required String userId,
    required DateTime encounterDate,
    required String title,
    required String fileUrl,
    required String fileType,
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
    required String journeyId,
    required List<String> selectedReportIds,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) = _MixView;

  factory MixView.fromJson(Map<String, dynamic> json) => _$MixViewFromJson(json);
}
