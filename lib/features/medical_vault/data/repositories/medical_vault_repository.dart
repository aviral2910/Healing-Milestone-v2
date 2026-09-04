import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import '../models/medical_vault_models.dart';

part 'medical_vault_repository.g.dart';

class MedicalVaultRepository {
  final ApiClient _apiClient;
  final Dio _dio = Dio(); // For direct Cloudflare upload without API interceptors

  MedicalVaultRepository(this._apiClient);

  Future<List<MedicalRecord>> getMedicalRecords() async {
    final response = await _apiClient.dio.get('/api/reports');
    return (response.data as List).map((json) => MedicalRecord.fromJson(json)).toList();
  }

  Future<MedicalRecord> uploadReport({
    required File file,
    required String fileName,
    required String title,
    required DateTime encounterDate,
  }) async {
    final fileType = _getFileType(fileName);

    // 1. Get Presigned URL
    final presignedResponse = await _apiClient.dio.get(
      '/api/reports/upload-url',
      queryParameters: {
        'file_name': fileName,
        'file_type': fileType,
      },
    );
    
    final uploadUrl = presignedResponse.data['uploadUrl'];
    final fileUrl = presignedResponse.data['fileUrl'];

    // 2. Upload directly to Cloudflare R2
    // We use a raw Dio instance here so our API interceptors (Auth headers) don't break the S3 signature
    await _dio.put(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: await file.length(),
          Headers.contentTypeHeader: fileType,
        },
      ),
    );

    // 3. Save to backend
    final response = await _apiClient.dio.post(
      '/api/reports',
      data: {
        'encounterDate': encounterDate.toIso8601String().split('T').first,
        'title': title,
        'fileUrl': fileUrl,
        'fileType': fileType,
      },
    );

    return MedicalRecord.fromJson(response.data);
  }

  Future<void> deleteReport(String id) async {
    await _apiClient.dio.delete('/api/reports/$id');
  }

  // --- Mix Views ---

  Future<List<MixView>> getMixViews() async {
    final response = await _apiClient.dio.get('/api/mix-views');
    return (response.data as List).map((json) => MixView.fromJson(json)).toList();
  }

  Future<MixView> createMixView({
    required String name,
    required String journeyId,
    required List<String> selectedReportIds,
    required int durationHours,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/mix-views',
      data: {
        'name': name,
        'journeyId': journeyId,
        'selectedReportIds': selectedReportIds,
        'durationHours': durationHours,
      },
    );
    return MixView.fromJson(response.data);
  }

  Future<void> revokeMixView(String id) async {
    await _apiClient.dio.delete('/api/mix-views/$id');
  }

  String _getFileType(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) return 'application/pdf';
    if (fileName.toLowerCase().endsWith('.png')) return 'image/png';
    if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}

@riverpod
MedicalVaultRepository medicalVaultRepository(Ref ref) {
  return MedicalVaultRepository(ref.watch(apiClientProvider));
}
