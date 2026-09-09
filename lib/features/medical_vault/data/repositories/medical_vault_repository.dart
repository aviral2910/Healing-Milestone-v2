import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:healing_milestones/core/network/api_client.dart';

import '../models/medical_vault_models.dart';
import '../models/biomarker_model.dart';

part 'medical_vault_repository.g.dart';

class MedicalVaultRepository {
  final ApiClient _apiClient;
  final Dio _dio =
      Dio(); // For direct Cloudflare upload without API interceptors

  MedicalVaultRepository(this._apiClient);

  Future<List<SnapshotTimelineItem>> getMixViewTimeline(
    String viewId, {
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/mix-views/$viewId/timeline',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return (response.data as List)
          .map((json) => SnapshotTimelineItem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch snapshot timeline: $e');
    }
  }

  Future<List<String>> getUniqueTags() async {
    try {
      final response = await _apiClient.dio.get('/api/reports/tags/unique');
      final List<dynamic> data = response.data;
      return data.cast<String>();
    } catch (e) {
      throw Exception('Error fetching unique tags: $e');
    }
  }

  Future<List<String>> getMedicalRecordIds({
    DateTime? afterDate,
    List<String>? tags,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (afterDate != null) {
        queryParams['after_date'] = afterDate.toIso8601String();
      }
      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }

      final response = await _apiClient.dio.get(
        '/api/reports/ids',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> data = response.data;
      return data.cast<String>();
    } catch (e) {
      throw Exception('Error fetching medical record IDs: $e');
    }
  }

  Future<List<MedicalRecord>> getMedicalRecords({
    int skip = 0,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/reports?skip=$skip&limit=$limit',
    );
    return (response.data as List)
        .map((json) => MedicalRecord.fromJson(json))
        .toList();
  }

  Future<List<MedicalRecordFile>> uploadFiles(List<PlatformFile> files) async {
    final processedFiles = <File>[];
    final requestFiles = <Map<String, dynamic>>[];

    // 1. Process files (compress images)
    final tempDir = await getTemporaryDirectory();

    for (int i = 0; i < files.length; i++) {
      final pf = files[i];
      final originalFile = File(pf.path!);
      final ext = pf.name.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        final targetPath =
            '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
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

          final originalNameWithoutExt = pf.name.substring(
            0,
            pf.name.lastIndexOf('.'),
          );
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
    await Future.wait(
      urlsList.asMap().entries.map((entry) async {
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
          'fileName': requestFiles[index]['fileName'],
        });
      }),
    );

    return uploadedFiles
        .map(
          (f) => MedicalRecordFile(
            url: f['url'],
            fileName: f['fileName'],
            fileType: f['fileType'],
          ),
        )
        .toList();
  }

  Future<MedicalRecord> uploadReport({
    required List<PlatformFile> files,
    required List<String> reportTypes,
    required DateTime encounterDate,
    required String category,
    String? notes,
  }) async {
    final uploadedFiles = await uploadFiles(files);

    // 4. Create record in DB
    final response = await _apiClient.dio.post(
      '/api/reports',
      data: {
        'encounterDate': encounterDate.toIso8601String().split('T').first,
        'reportTypes': reportTypes,
        'files': uploadedFiles.map((f) => f.toJson()).toList(),
        'category': category,
        'notes': notes,
      },
    );

    return MedicalRecord.fromJson(response.data);
  }

  Future<MedicalRecord> updateReport({
    required String id,
    required List<String> reportTypes,
    required DateTime encounterDate,
    required List<MedicalRecordFile> files,
    required String category,
    String? notes,
  }) async {
    final response = await _apiClient.dio.put(
      '/api/reports/$id',
      data: {
        'encounterDate': encounterDate.toIso8601String().split('T').first,
        'reportTypes': reportTypes,
        'files': files.map((f) => f.toJson()).toList(),
        'category': category,
        'notes': notes,
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
    return (response.data as List)
        .map((json) => MixView.fromJson(json))
        .toList();
  }

  Future<MixView> createMixView({
    required String name,
    required List<String> journeyIds,
    required List<String> selectedReportIds,
    required int durationHours,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/mix-views',
      data: {
        'name': name,
        'journeyIds': journeyIds,
        'selectedReportIds': selectedReportIds,
        'durationHours': durationHours,
      },
    );
    return MixView.fromJson(response.data);
  }

  Future<MixView> updateMixView({
    required String id,
    required String name,
    required List<String> journeyIds,
    required List<String> selectedReportIds,
    required int durationHours,
  }) async {
    final response = await _apiClient.dio.put(
      '/api/mix-views/$id',
      data: {
        'name': name,
        'journeyIds': journeyIds,
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
    if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg'))
      return 'image/jpeg';
    return 'application/octet-stream';
  }

  Future<List<String>> searchReportTags(String query) async {
    final response = await _apiClient.dio.get(
      '/api/reports/tags',
      queryParameters: {'q': query},
    );
    return (response.data as List).map((e) => e.toString()).toList();
  }

  Future<List<BiomarkerModel>> extractBiomarkers(List<String> fileUrls) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/reports/extract',
        data: {'fileUrls': fileUrls},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BiomarkerModel.fromJson(json)).toList();
      }
      throw Exception('Failed to extract biomarkers: ${response.statusCode}');
    } catch (e) {
      throw Exception('Extraction error: $e');
    }
  }

  Future<List<BiomarkerModel>> saveBiomarkers(
    String recordId,
    List<BiomarkerModel> biomarkers,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/reports/$recordId/biomarkers',
        data: biomarkers.map((b) => b.toJson()).toList(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BiomarkerModel.fromJson(json)).toList();
      }
      throw Exception('Failed to save biomarkers: ${response.statusCode}');
    } catch (e) {
      throw Exception('Save error: $e');
    }
  }

  Future<BiomarkerModel> updateBiomarker(
    String biomarkerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/reports/biomarkers/$biomarkerId',
        data: updates,
      );
      if (response.statusCode == 200) {
        return BiomarkerModel.fromJson(response.data);
      }
      throw Exception('Failed to update biomarker');
    } catch (e) {
      throw Exception('Update error: $e');
    }
  }

  Future<List<BiomarkerModel>> extractAndSaveBiomarkers(
    String recordId,
    List<String> fileUrls,
  ) async {
    final extracted = await extractBiomarkers(fileUrls);
    if (extracted.isEmpty) return [];
    return await saveBiomarkers(recordId, extracted);
  }

  Future<List<BiomarkerTrendModel>> getBiomarkerTrends() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/reports/biomarkers/trends',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BiomarkerTrendModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load trends: ${response.statusCode}');
    } catch (e) {
      throw Exception('Load trends error: $e');
    }
  }

  Future<List<BiomarkerTemplate>> searchBiomarkerDictionary(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/biomarker-dictionary/search',
        queryParameters: {'q': query, 'limit': 20},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BiomarkerTemplate.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return []; // Fail silently for autocomplete
    }
  }
}

@riverpod
MedicalVaultRepository medicalVaultRepository(Ref ref) {
  return MedicalVaultRepository(ref.watch(apiClientProvider));

}

class BiomarkerTemplate {
  final String name;
  final String? unit;
  
  BiomarkerTemplate({required this.name, this.unit});
  
  factory BiomarkerTemplate.fromJson(Map<String, dynamic> json) {
    return BiomarkerTemplate(
      name: json['name'] as String,
      unit: json['unit'] as String?,
    );
  }
}
