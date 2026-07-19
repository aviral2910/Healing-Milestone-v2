import 'dart:io';

abstract class StorageRepository {
  Future<String> uploadImage(String path, File file);
  Future<void> deleteImage(String path);
  Future<void> deleteImageFromUrl(String url);
}
