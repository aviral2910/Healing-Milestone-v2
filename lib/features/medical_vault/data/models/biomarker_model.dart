import 'package:freezed_annotation/freezed_annotation.dart';

part 'biomarker_model.freezed.dart';
part 'biomarker_model.g.dart';

@freezed
abstract class BiomarkerModel with _$BiomarkerModel {
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
abstract class TrendDataPoint with _$TrendDataPoint {
  const factory TrendDataPoint({
    required DateTime date,
    required double value,
    @JsonKey(name: 'is_abnormal', readValue: _readIsAbnormal) bool? isAbnormal,
    @JsonKey(name: 'record_id', readValue: _readRecordId) required String recordId,
    @JsonKey(name: 'range_low', readValue: _readRangeLow) double? rangeLow,
    @JsonKey(name: 'range_high', readValue: _readRangeHigh) double? rangeHigh,
  }) = _TrendDataPoint;

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendDataPointFromJson(json);
}

@freezed
abstract class BiomarkerTrendModel with _$BiomarkerTrendModel {
  const factory BiomarkerTrendModel({
    required String name,
    String? unit,
    @JsonKey(name: 'data_points', readValue: _readDataPoints) @Default([]) List<TrendDataPoint> dataPoints,
  }) = _BiomarkerTrendModel;

  factory BiomarkerTrendModel.fromJson(Map<String, dynamic> json) =>
      _$BiomarkerTrendModelFromJson(json);
}

// Helper to read both camelCase and snake_case safely
bool? _readIsAbnormal(Map p1, String p2) => p1['isAbnormal'] ?? p1['is_abnormal'];
String _readRecordId(Map p1, String p2) => p1['recordId'] ?? p1['record_id'];
List _readDataPoints(Map p1, String p2) => p1['dataPoints'] ?? p1['data_points'] ?? [];

double? _readRangeLow(Map p1, String p2) {
  final val = p1['rangeLow'] ?? p1['range_low'];
  if (val == null) return null;
  return (val as num).toDouble();
}

double? _readRangeHigh(Map p1, String p2) {
  final val = p1['rangeHigh'] ?? p1['range_high'];
  if (val == null) return null;
  return (val as num).toDouble();
}
