import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
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
    required List<PlatformFile> files,
    required List<String> reportTypes,
    required DateTime encounterDate,
  }) async {
    final processedFiles = <File>[];
    final requestFiles = <Map<String, dynamic>>[];
    
    // 1. Process files (compress images)
    final tempDir = await getTemporaryDirectory();
    
    for (int i = 0; i < files.length; i++) {
      final pf = files[i];
      final originalFile = File(pf.path!);
      final ext = pf.name.split('.').last.toLowerCase();
      
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          targetPath,
          minWidth: 1440,
          minHeight: 1440,
          quality: 85,
          format: CompressFormat.jpeg,
        );
        
        if (compressedFile != null) {
          final fileObj = File(compressedFile.path);
          processedFiles.add(fileObj);
          
          final originalNameWithoutExt = pf.name.substring(0, pf.name.lastIndexOf('.'));
          requestFiles.add({
            'fileName': '${originalNameWithoutExt}.jpg',
            'fileType': 'image/jpeg',
          });
        } else {
          processedFiles.add(originalFile);
          requestFiles.add({
            'fileName': pf.name,
            'fileType': _getFileType(pf.name),
          });
        }
      } else {
        processedFiles.add(originalFile);
        requestFiles.add({
          'fileName': pf.name,
          'fileType': _getFileType(pf.name),
        });
      }
    }
    
    // 2. Get Presigned URLs for all files
    final presignedResponse = await _apiClient.dio.post(
      '/api/reports/upload-urls',
      data: {'files': requestFiles},
    );
    
    final urlsList = presignedResponse.data['urls'] as List;
    final uploadedFiles = <Map<String, dynamic>>[];

    // 3. Upload directly to Cloudflare R2 concurrently
    await Future.wait(urlsList.asMap().entries.map((entry) async {
      final index = entry.key;
      final urlData = entry.value;
      final file = processedFiles[index];
      
      await _dio.put(
        urlData['uploadUrl'],
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: await file.length(),
            Headers.contentTypeHeader: urlData['fileType'],
          },
        ),
      );
      
      uploadedFiles.add({
        'url': urlData['fileUrl'],
        'fileType': urlData['fileType'],
        'fileName': urlData['fileName'],
      });
    }));

    // 3. Save to backend
    final response = await _apiClient.dio.post(
      '/api/reports',
      data: {
        'encounterDate': encounterDate.toIso8601String().split('T').first,
        'reportTypes': reportTypes,
        'files': uploadedFiles,
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

  Future<List<String>> searchReportTags(String query) async {
    final response = await _apiClient.dio.get(
      '/api/reports/tags',
      queryParameters: {'q': query},
    );
    return (response.data as List).map((e) => e.toString()).toList();
  }
}

@riverpod
MedicalVaultRepository medicalVaultRepository(Ref ref) {
  return MedicalVaultRepository(ref.watch(apiClientProvider));
}
