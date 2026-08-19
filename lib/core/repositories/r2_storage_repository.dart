import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'storage_repository.dart';
import '../network/api_client.dart';

class R2StorageRepository implements StorageRepository {
  final ApiClient _apiClient;
  final Dio _dio = Dio(); // Clean Dio instance for external S3 uploads

  R2StorageRepository(this._apiClient);

  @override
  Future<String> uploadImage(String path, File file) async {
    // 1. Compress the image before uploading
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1920,
      minHeight: 1920,
      quality: 100,
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
    if (url.isEmpty || !url.contains('r2.dev')) return;
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
