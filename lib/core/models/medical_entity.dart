import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_entity.freezed.dart';
part 'medical_entity.g.dart';

@freezed
abstract class MedicalEntity with _$MedicalEntity {
  const factory MedicalEntity({
    required String entityId,
    required String name,
    required String type, // "doctor" or "hospital"
  }) = _MedicalEntity;

  factory MedicalEntity.fromJson(Map<String, dynamic> json) => _$MedicalEntityFromJson(json);
}
