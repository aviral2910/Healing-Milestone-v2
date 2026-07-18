import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'storage_repository.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage _storage;

  FirebaseStorageRepository(this._storage);

  @override
  Future<String> uploadImage(String path, File file) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Future<void> deleteImage(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}
