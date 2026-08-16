import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      try {
        return UserModel.fromMap(doc.data()!);
      } catch (e) {
        print("Error parsing user data: $e");
        return null;
      }
    }
    return null;
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        try {
          return UserModel.fromMap(doc.data()!);
        } catch (e) {
          print("Error parsing user stream data: $e");
          return null;
        }
      }
      return null;
    });
  }

  @override
  Future<void> createUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toMap());
  }

  @override
  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).update(user.toMap());
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: cleanQuery)
          .where('username', isLessThan: '$cleanQuery\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    
    List<UserModel> result = [];
    // Firestore 'whereIn' supports max 30 items
    for (int i = 0; i < uids.length; i += 30) {
      final chunk = uids.sublist(i, i + 30 > uids.length ? uids.length : i + 30);
      final snapshot = await _firestore
          .collection('users')
          .where('userId', whereIn: chunk)
          .get();
          
      result.addAll(snapshot.docs.map((doc) => UserModel.fromMap(doc.data())));
    }
    
    // Maintain the order of the original uids list
    final userMap = {for (var user in result) user.userId: user};
    return uids.where((uid) => userMap.containsKey(uid)).map((uid) => userMap[uid]!).toList();
  }

  @override
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      final currentUserDoc = await transaction.get(currentUserRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!currentUserDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final targetUserData = targetUserDoc.data() as Map<String, dynamic>;

      final followingList = List<String>.from(currentUserData['followingList'] ?? []);
      int followingCount = currentUserData['followingCount'] ?? 0;

      final followersList = List<String>.from(targetUserData['followersList'] ?? []);
      int followersCount = targetUserData['followersCount'] ?? 0;

      if (followingList.contains(targetUserId)) {
        // Unfollow
        followingList.remove(targetUserId);
        followingCount--;
        
        followersList.remove(currentUserId);
        followersCount--;
      } else {
        // Follow
        followingList.add(targetUserId);
        followingCount++;
        
        followersList.add(currentUserId);
        followersCount++;
      }

      transaction.update(currentUserRef, {
        'followingList': followingList,
        'followingCount': followingCount,
      });

      transaction.update(targetUserRef, {
        'followersList': followersList,
        'followersCount': followersCount,
      });
    });
  }

  @override
  Future<void> toggleBookmark(String userId, String storyId) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final bookmarkedStories = List<String>.from(userData['bookmarkedStories'] ?? []);

      if (bookmarkedStories.contains(storyId)) {
        bookmarkedStories.remove(storyId);
      } else {
        bookmarkedStories.add(storyId);
      }

      transaction.update(userRef, {
        'bookmarkedStories': bookmarkedStories,
      });
    });
  }

  @override
  Future<void> deleteUserData() async {
    throw UnimplementedError('Not implemented for Firebase backend (using API backend).');
  }
  @override
  Future<List<UserModel>> getFollowers(String uid, {int skip = 0, int limit = 20}) async {
    return []; // Not implemented for legacy firebase
  }

  @override
  Future<List<UserModel>> getFollowing(String uid, {int skip = 0, int limit = 20}) async {
    return []; // Not implemented for legacy firebase
  }
}