import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:trace_craft/models/gallery_post_model.dart';

class FirestoreService {
  static const String postsCollection = 'gallery_posts';

  static final List<GalleryPost> _fallbackPosts = [
    GalleryPost(
      id: 'post_1',
      authorId: 'user_sophia',
      authorName: 'Sophia Jenkins',
      authorAvatarUrl: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Graphite Portrait Tracing',
      description: 'Drawn using TraceCraft at 45% opacity on 300gsm cold-press watercolor paper with 2B & 4B pencils.',
      tags: ['portrait', 'pencil', 'shading'],
      likesCount: 156,
      likedUserIds: ['user_sample_1'],
      averageRating: 4.9,
      totalRatingsCount: 42,
      userRatings: {'user_sample_1': 5.0, 'user_sample_2': 5.0, 'user_sample_3': 4.8},
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    GalleryPost(
      id: 'post_2',
      authorId: 'user_marcus',
      authorName: 'Marcus Vance',
      authorAvatarUrl: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/247502/pexels-photo-247502.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/247502/pexels-photo-247502.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Lion Mane Ink Sketch',
      description: 'Used the Sobel Line-Art mode to extract edge contours first, then inked with 0.3mm fineliner.',
      tags: ['wildlife', 'ink', 'lineart'],
      likesCount: 98,
      likedUserIds: [],
      averageRating: 4.7,
      totalRatingsCount: 29,
      userRatings: {'user_sample_1': 4.5},
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    GalleryPost(
      id: 'post_3',
      authorId: 'user_elena',
      authorName: 'Elena Rostova',
      authorAvatarUrl: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Botanical Rose Drawing',
      description: 'First attempt with the proportion grid overlay enabled. Proportions came out exact!',
      tags: ['botanical', 'flowers', 'beginner'],
      likesCount: 64,
      likedUserIds: [],
      averageRating: 4.6,
      totalRatingsCount: 19,
      userRatings: {},
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Fetches community gallery posts from Firestore
  static Future<List<GalleryPost>> fetchPosts({String filter = 'trending'}) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final collection = FirebaseFirestore.instance.collection(postsCollection);
        Query query;
        if (filter == 'trending') {
          query = collection.orderBy('averageRating', descending: true);
        } else {
          query = collection.orderBy('createdAt', descending: true);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            return GalleryPost.fromJson(doc.data() as Map<String, dynamic>, documentId: doc.id);
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('FirestoreService fetchPosts note: $e');
    }

    // Return fallback list sorted
    final list = List<GalleryPost>.from(_fallbackPosts);
    if (filter == 'trending') {
      list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  /// Creates a new artwork post in Cloud Firestore
  static Future<void> createPost(GalleryPost post) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection(postsCollection).doc(post.id).set(post.toJson());
        return;
      }
    } catch (e) {
      debugPrint('FirestoreService createPost note: $e');
    }

    _fallbackPosts.insert(0, post);
  }

  /// Toggles like counter with atomic transaction (one like per user)
  static Future<GalleryPost?> toggleLike(String postId, String userId) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final docRef = FirebaseFirestore.instance.collection(postsCollection).doc(postId);
        return await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) return null;

          final data = snapshot.data()!;
          final likedUsers = List<String>.from(data['likedUserIds'] ?? []);
          int currentLikes = (data['likesCount'] as num?)?.toInt() ?? 0;

          if (likedUsers.contains(userId)) {
            likedUsers.remove(userId);
            currentLikes = (currentLikes - 1).clamp(0, 999999);
          } else {
            likedUsers.add(userId);
            currentLikes += 1;
          }

          transaction.update(docRef, {
            'likedUserIds': likedUsers,
            'likesCount': currentLikes,
          });

          return GalleryPost.fromJson(data, documentId: postId).copyWith(
            likedUserIds: likedUsers,
            likesCount: currentLikes,
          );
        });
      }
    } catch (e) {
      debugPrint('FirestoreService toggleLike note: $e');
    }

    // Local fallback update
    final index = _fallbackPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _fallbackPosts[index];
      final likedUsers = List<String>.from(post.likedUserIds);
      int likes = post.likesCount;

      if (likedUsers.contains(userId)) {
        likedUsers.remove(userId);
        likes = (likes - 1).clamp(0, 999999);
      } else {
        likedUsers.add(userId);
        likes += 1;
      }

      final updated = post.copyWith(likedUserIds: likedUsers, likesCount: likes);
      _fallbackPosts[index] = updated;
      return updated;
    }
    return null;
  }

  /// Rates post 1 to 5 stars, stores user rating, and updates average rating on doc
  static Future<GalleryPost?> ratePost(String postId, String userId, double rating) async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final docRef = FirebaseFirestore.instance.collection(postsCollection).doc(postId);
        return await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) return null;

          final data = snapshot.data()!;
          final ratingsMap = Map<String, dynamic>.from(data['userRatings'] ?? {});
          ratingsMap[userId] = rating;

          final ratings = ratingsMap.values.map((v) => (v as num).toDouble()).toList();
          final totalCount = ratings.length;
          final double avg = totalCount > 0 ? (ratings.reduce((a, b) => a + b) / totalCount) : 0.0;
          final roundedAvg = double.parse(avg.toStringAsFixed(1));

          transaction.update(docRef, {
            'userRatings': ratingsMap,
            'averageRating': roundedAvg,
            'totalRatingsCount': totalCount,
          });

          return GalleryPost.fromJson(data, documentId: postId).copyWith(
            userRatings: ratingsMap.map((k, v) => MapEntry(k, (v as num).toDouble())),
            averageRating: roundedAvg,
            totalRatingsCount: totalCount,
          );
        });
      }
    } catch (e) {
      debugPrint('FirestoreService ratePost note: $e');
    }

    // Local fallback update
    final index = _fallbackPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _fallbackPosts[index];
      final map = Map<String, double>.from(post.userRatings);
      map[userId] = rating;

      final ratings = map.values.toList();
      final double avg = ratings.reduce((a, b) => a + b) / ratings.length;
      final roundedAvg = double.parse(avg.toStringAsFixed(1));

      final updated = post.copyWith(
        userRatings: map,
        averageRating: roundedAvg,
        totalRatingsCount: ratings.length,
      );
      _fallbackPosts[index] = updated;
      return updated;
    }
    return null;
  }

  /// Writes user feedback to Firestore "feedback" collection
  static Future<bool> submitFeedback({
    required String category,
    required String message,
    required double rating,
    String? userEmail,
    String? userId,
  }) async {
    final feedbackData = {
      'category': category,
      'message': message,
      'rating': rating,
      'userEmail': userEmail ?? 'anonymous',
      'userId': userId ?? 'anonymous',
      'createdAt': FieldValue.serverTimestamp(),
      'platform': defaultTargetPlatform.name,
    };

    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('feedback').add(feedbackData);
        debugPrint('FirestoreService: Feedback submitted to Firestore.');
        return true;
      }
    } catch (e) {
      debugPrint('FirestoreService submitFeedback note: $e');
    }

    debugPrint('FirestoreService: Local feedback recorded: $feedbackData');
    return true;
  }
}
