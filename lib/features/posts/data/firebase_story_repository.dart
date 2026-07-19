import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'story_repository.dart';

class FirebaseStoryRepository implements StoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseStoryRepository(this._firestore);

  CollectionReference get _stories => _firestore.collection('stories');

  @override
  Stream<List<StoryModel>> getStories() {
    return _stories.orderBy('publishedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  @override
  Stream<List<StoryModel>> getUserStories(String userId) {
    return _stories.where('authorId', isEqualTo: userId).snapshots().map((snapshot) {
      final stories = snapshot.docs.map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      stories.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return stories;
    });
  }

  @override
  Stream<List<StoryModel>> getStoriesTaggedWithUser(String userId) {
    return _stories.where('taggedPeople', arrayContains: userId).snapshots().map((snapshot) {
      final stories = snapshot.docs.map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      stories.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return stories;
    });
  }

  @override
  Future<List<StoryModel>> getStoriesByHashtag(String hashtag, {int limit = 20}) async {
    final querySnapshot = await _stories
        .where('hashtagsList', arrayContains: hashtag)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Stream<StoryModel?> getStoryById(String storyId) {
    return _stories.doc(storyId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return StoryModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  @override
  Future<void> createStory(StoryModel story) async {
    await _stories.doc(story.storyId).set(story.toMap());
  }

  @override
  Future<void> updateStory(StoryModel story) async {
    await _stories.doc(story.storyId).update(story.toMap());
  }

  @override
  Future<void> deleteStory(String storyId) async {
    await _stories.doc(storyId).delete();
  }

  @override
  Future<void> toggleLike(String storyId, String userId) async {
    final docRef = _stories.doc(storyId);
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;
      
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final likesList = List<String>.from(data['likesList'] ?? []);
      int likesCount = data['likesCount'] ?? 0;

      final userData = userDoc.data() as Map<String, dynamic>;
      final likedStories = List<String>.from(userData['likedStories'] ?? []);

      if (likesList.contains(userId)) {
        likesList.remove(userId);
        likesCount--;
        likedStories.remove(storyId);
      } else {
        likesList.add(userId);
        likesCount++;
        likedStories.add(storyId);
      }

      transaction.update(docRef, {
        'likesList': likesList,
        'likesCount': likesCount,
      });

      transaction.update(userRef, {
        'likedStories': likedStories,
      });
    });
  }

  @override
  Future<List<StoryModel>> getStoriesByIds(List<String> storyIds) async {
    if (storyIds.isEmpty) return [];
    
    // Firestore whereIn has a limit of 30 items
    final chunks = <List<String>>[];
    for (var i = 0; i < storyIds.length; i += 30) {
      chunks.add(storyIds.sublist(i, i + 30 > storyIds.length ? storyIds.length : i + 30));
    }

    final allStories = <StoryModel>[];
    for (final chunk in chunks) {
      final snapshot = await _stories.where(FieldPath.documentId, whereIn: chunk).get();
      allStories.addAll(
        snapshot.docs.map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      );
    }
    
    // Maintain the order of the original storyIds list (e.g. most recently bookmarked first)
    final storyMap = {for (var story in allStories) story.storyId: story};
    return storyIds.map((id) => storyMap[id]).whereType<StoryModel>().toList();
  }
}
