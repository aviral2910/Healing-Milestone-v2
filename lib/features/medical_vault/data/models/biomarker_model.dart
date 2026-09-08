import 'package:freezed_annotation/freezed_annotation.dart';

part 'biomarker_model.freezed.dart';
part 'biomarker_model.g.dart';

@freezed
class BiomarkerModel with _$BiomarkerModel {
  const factory BiomarkerModel({
    String? id,
    String? recordId,
    required String rawName,
    String? rawUnit,
    required String resultType,
    double? valueNumeric,
    String? valueText,
    bool? isAbnormal,
    String? aiPredictedLoinc,
    String? aiPredictedStandardName,
    String? dictionaryId,
  }) = _BiomarkerModel;

  factory BiomarkerModel.fromJson(Map<String, dynamic> json) =>
      _$BiomarkerModelFromJson(json);
}

@freezed
class TrendDataPoint with _$TrendDataPoint {
  const factory TrendDataPoint({
    required DateTime date,
    required double value,
    bool? isAbnormal,
    required String recordId,
  }) = _TrendDataPoint;

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendDataPointFromJson(json);
}

@freezed
class BiomarkerTrendModel with _$BiomarkerTrendModel {
  const factory BiomarkerTrendModel({
    required String name,
    String? unit,
    @Default([]) List<TrendDataPoint> dataPoints,
  }) = _BiomarkerTrendModel;

  factory BiomarkerTrendModel.fromJson(Map<String, dynamic> json) =>
      _$BiomarkerTrendModelFromJson(json);
}
