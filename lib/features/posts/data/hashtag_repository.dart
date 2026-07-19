import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hashtagRepositoryProvider = Provider<HashtagRepository>((ref) {
  return HashtagRepository(FirebaseFirestore.instance);
});

final trendingHashtagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(hashtagRepositoryProvider);
  return repository.getTrendingHashtags(limit: 50);
});

class HashtagRepository {
  final FirebaseFirestore _firestore;

  HashtagRepository(this._firestore);

  /// Fetches the top trending hashtags (cached locally automatically by Firestore)
  Future<List<String>> getTrendingHashtags({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('hashtags')
          .orderBy('postCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching trending hashtags: $e');
      return [];
    }
  }

  /// Searches the database for a specific hashtag prefix
  Future<List<String>> searchHashtags(String query) async {
    try {
      final cleanQuery = query.toLowerCase().trim();
      if (cleanQuery.isEmpty) return [];

      // A simple prefix search in Firestore on documentId
      final snapshot = await _firestore
          .collection('hashtags')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: cleanQuery)
          .where(FieldPath.documentId, isLessThan: '$cleanQuery\uf8ff')
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error searching hashtags: $e');
      return [];
    }
  }
}
