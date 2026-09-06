import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../journey/data/models/journey_models.dart';

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

@freezed
abstract class SnapshotTimelineItem with _$SnapshotTimelineItem {
  const factory SnapshotTimelineItem.milestone({
    required JourneyMilestoneModel data,
    required DateTime date,
  }) = _MilestoneItem;

  const factory SnapshotTimelineItem.record({
    required MedicalRecord data,
    required DateTime date,
  }) = _RecordItem;

  factory SnapshotTimelineItem.fromJson(Map<String, dynamic> json) {
    final type = json['item_type'] as String;
    final dateStr = json['date'] as String;
    final date = DateTime.parse((dateStr.endsWith('Z') || dateStr.contains(RegExp(r'[+-]\d{2}:\d{2}$'))) ? dateStr : '${dateStr}Z').toLocal();
    if (type == 'milestone') {
      return SnapshotTimelineItem.milestone(
        data: JourneyMilestoneModel.fromJson(json['data'] as Map<String, dynamic>),
        date: date,
      );
    } else if (type == 'record') {
      return SnapshotTimelineItem.record(
        data: MedicalRecord.fromJson(json['data'] as Map<String, dynamic>),
        date: date,
      );
    }
    throw Exception('Unknown item_type: $type');
  }
}
