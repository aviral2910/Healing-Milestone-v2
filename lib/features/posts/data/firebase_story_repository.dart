import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'story_repository.dart';

class FirebaseStoryRepository implements StoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseStoryRepository(this._firestore);

  CollectionReference get _stories => _firestore.collection('stories');

  @override
  Stream<List<StoryModel>> getStories() {
    return _stories.orderBy('publishedAt', descending: true).snapshots().map((snapshot) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((story) => !story.isHidden || story.authorId == currentUserId)
          .toList();
    });
  }

  @override
  Future<({List<StoryModel> stories, dynamic lastDoc})> getPaginatedStories({dynamic startAfter, int limit = 5}) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    Query query = _stories.orderBy('publishedAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter as DocumentSnapshot);
    }
    
    final snapshot = await query.get();
    final stories = snapshot.docs
        .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((story) => !story.isHidden || story.authorId == currentUserId)
        .toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    
    return (stories: stories, lastDoc: lastDoc);
  }

  @override
  Stream<List<StoryModel>> getUserStories(String userId) {
    return _stories.where('authorId', isEqualTo: userId).snapshots().map((snapshot) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final stories = snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((story) => !story.isHidden || story.authorId == currentUserId)
          .toList();
      stories.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return stories;
    });
  }

  @override
  Stream<List<StoryModel>> getStoriesTaggedWithUser(String userId) {
    return _stories.where('taggedPeople', arrayContains: userId).snapshots().map((snapshot) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final stories = snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((story) => !story.isHidden || story.authorId == currentUserId)
          .toList();
      stories.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return stories;
    });
  }

  @override
  Future<List<StoryModel>> getStoriesByHashtag(String hashtag, {int limit = 20}) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final querySnapshot = await _stories
        .where('hashtagsList', arrayContains: hashtag)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((story) => !story.isHidden || story.authorId == currentUserId)
        .toList();
  }

  @override
  Stream<List<StoryModel>> watchStoriesByHashtag(String hashtag, {int limit = 20}) {
    return _stories
        .where('hashtagsList', arrayContains: hashtag)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          return snapshot.docs
            .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((story) => !story.isHidden || story.authorId == currentUserId)
            .toList();
        });
  }

  @override
  Stream<StoryModel?> getStoryById(String storyId) {
    return _stories.doc(storyId).snapshots().map((snapshot) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (!snapshot.exists) return null;
      final story = StoryModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
      if (story.isHidden && story.authorId != currentUserId) return null;
      return story;
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
  Future<void> toggleReaction(String storyId, String userId, String reactionType) async {
    final docRef = _stories.doc(storyId);
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;
      
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      
      // Parse reactions map
      final Map<String, dynamic> rawReactions = data['reactions'] ?? {};
      final Map<String, List<String>> reactions = rawReactions.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
      
      // For backward compatibility
      final likesList = List<String>.from(data['likesList'] ?? []);
      int likesCount = data['likesCount'] ?? 0;

      final userData = userDoc.data() as Map<String, dynamic>;
      final likedStories = List<String>.from(userData['likedStories'] ?? []);

      // Check if user currently has ANY reaction
      String? currentReactionType;
      for (final entry in reactions.entries) {
        if (entry.value.contains(userId)) {
          currentReactionType = entry.key;
          break;
        }
      }
      
      // Check legacy likesList
      if (currentReactionType == null && likesList.contains(userId)) {
        currentReactionType = 'heart';
      }

      if (currentReactionType == reactionType) {
        // User tapped the same reaction they already had -> un-react
        if (reactions.containsKey(reactionType)) {
          reactions[reactionType]!.remove(userId);
        }
        likesList.remove(userId);
        likesCount = (likesCount - 1).clamp(0, double.infinity).toInt();
        likedStories.remove(storyId);
      } else {
        // User changed reaction or added new reaction
        
        // Remove from old reaction if exists
        if (currentReactionType != null) {
          if (reactions.containsKey(currentReactionType)) {
            reactions[currentReactionType]!.remove(userId);
          }
          if (currentReactionType == 'heart') {
            likesList.remove(userId);
          }
        } else {
          // It's a brand new reaction, increase count
          likesCount++;
          likedStories.add(storyId);
        }
        
        // Add to new reaction
        if (!reactions.containsKey(reactionType)) {
          reactions[reactionType] = [];
        }
        reactions[reactionType]!.add(userId);
        
        if (reactionType == 'heart') {
          likesList.add(userId);
        }
      }

      transaction.update(docRef, {
        'reactions': reactions,
        'likesList': likesList, // maintain backward compatibility
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

  @override
  Future<void> reportStory({required String storyId, required String reporterId, required String reason}) async {
    await _firestore.collection('reports').add({
      'storyId': storyId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // 'pending', 'dismissed', 'resolved'
    });
  }
}
