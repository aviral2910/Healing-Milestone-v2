import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'storage_repository.dart';
import '../network/api_client.dart';

class R2StorageRepository implements StorageRepository {
  @override
  Future<String> uploadAudio(File file) async {
    try {
      final bytesToUpload = await file.readAsBytes();
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.m4a';
      
      final urlResponse = await _apiClient.dio.get(
        '/api/media/presigned-url',
        queryParameters: {
          'file_type': 'm4a',
          'content_type': 'audio/m4a',
        },
      );
      
      final presignedUrl = urlResponse.data['upload_url'] as String;
      final publicUrl = urlResponse.data['public_url'] as String;
      
      final dio = Dio();
      await dio.put(
        presignedUrl,
        data: Stream.fromIterable([bytesToUpload]),
        options: Options(
          headers: {
            'Content-Type': 'audio/m4a',
            'Content-Length': bytesToUpload.length,
          },
        ),
      );
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  final ApiClient _apiClient;
  final Dio _dio = Dio(); // Clean Dio instance for external S3 uploads

  R2StorageRepository(this._apiClient);

  @override
  Future<String> uploadImage(String path, File file) async {
    // 1. Compress the image before uploading
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1440,
      minHeight: 1440,
      quality: 90,
      format: CompressFormat.jpeg,
    );

    final bytesToUpload = compressedBytes ?? await file.readAsBytes();
    final originalExtension = file.path.split('.').last.toLowerCase();
    
    // Dynamically set content type based on compression result
    final String contentType;
    final String finalExtension;
    
    if (compressedBytes != null) {
      contentType = 'image/jpeg';
      finalExtension = 'jpg';
    } else {
      if (originalExtension == 'png') {
        contentType = 'image/png';
      } else if (originalExtension == 'jpg' || originalExtension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (originalExtension == 'webp') {
        contentType = 'image/webp';
      } else {
        contentType = 'application/octet-stream';
      }
      finalExtension = originalExtension;
    }

    // 2. Ask backend for a presigned URL
    final response = await _apiClient.dio.get(
      '/api/media/presigned-url',
      queryParameters: {
        'file_type': finalExtension,
        'content_type': contentType,
      },
    );

    final data = response.data;
    final uploadUrl = data['upload_url'];
    final publicUrl = data['public_url'];

    // 3. Upload directly to Cloudflare R2
    await _dio.put(
      uploadUrl,
      data: Stream.fromIterable([bytesToUpload]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          Headers.contentLengthHeader: bytesToUpload.length,
        },
      ),
    );

    // 4. Return the public URL
    return publicUrl;
  }

  @override
  Future<void> deleteImage(String path) async {
    // Implementing delete via backend API is recommended for R2,
    // but for now, we leave it as a no-op or we can add a delete endpoint later.
    // Cloudflare R2 is so cheap we can often ignore orphans during prototyping.
  }

  @override
  Future<void> deleteImageFromUrl(String url) async {
    if (url.isEmpty || (!url.contains('r2.dev') && !url.contains('healingmilestones.com') && !url.contains('pub-'))) return;
    try {
      await _apiClient.dio.delete(
        '/api/media/delete',
        queryParameters: {'url': url},
      );
    } catch (e) {
      print('Failed to delete old image from R2: $e');
    }
  }
}
