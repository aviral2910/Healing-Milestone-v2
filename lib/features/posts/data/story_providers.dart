import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/repositories/firebase_storage_repository.dart';
import 'package:healing_milestones/core/repositories/storage_repository.dart';
import 'package:healing_milestones/features/posts/data/firebase_story_repository.dart';
import 'package:healing_milestones/features/posts/data/story_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return FirebaseStorageRepository(ref.watch(firebaseStorageProvider));
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return FirebaseStoryRepository(ref.watch(firebaseFirestoreProvider));
});

final storiesStreamProvider = StreamProvider<List<StoryModel>>((ref) {
  return ref.watch(storyRepositoryProvider).getStories();
});

final userStoriesProvider = StreamProvider.family<List<StoryModel>, String>((ref, userId) {
  return ref.watch(storyRepositoryProvider).getUserStories(userId);
});
