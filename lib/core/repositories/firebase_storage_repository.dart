import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'storage_repository.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage _storage;

  FirebaseStorageRepository(this._storage);

  @override
  Future<String> uploadImage(String path, File file) async {
    // Compress the image before uploading
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1080,
      minHeight: 1080,
      quality: 70,
      format: CompressFormat.webp,
    );

    if (compressedBytes != null) {
      // Ensure the path uses .webp extension
      final finalPath = path.replaceAll(RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false), '.webp');
      final ref = _storage.ref().child(finalPath);
      final uploadTask = ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/webp'),
      );
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } else {
      // Fallback to original file if compression fails
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    }
  }

  @override
  Future<void> deleteImage(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  @override
  Future<void> deleteImageFromUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore if image doesn't exist or URL is invalid
    }
  }
}
