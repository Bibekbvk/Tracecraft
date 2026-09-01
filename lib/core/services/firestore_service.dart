import 'package:flutter/foundation.dart';
import 'package:trace_craft/features/gallery/domain/models/gallery_post.dart';

class CommunityGalleryService {
  // In-memory + local persisted cache for offline-first community posts
  static final List<GalleryPost> _initialPosts = [
    GalleryPost(
      id: 'post_1',
      authorId: 'user_sophia',
      authorName: 'Sophia Jenkins',
      authorAvatarUrl: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Graphite Portrait Sketch with Camera Lucida',
      description: 'Used TraceCraft with 45% opacity and line-art filter on a cold press paper. Completed in 45 mins!',
      tags: ['portrait', 'graphite', 'shading', 'beginner'],
      likesCount: 142,
      averageRating: 4.8,
      totalRatingsCount: 38,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    GalleryPost(
      id: 'post_2',
      authorId: 'user_alex',
      authorName: 'Alex Rivera',
      authorAvatarUrl: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/247502/pexels-photo-247502.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/247502/pexels-photo-247502.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Lion Mane Study - 0.5mm Fineliner',
      description: 'The grid overlay tool helped immensely to lock the proportions before tracing the fine hair strands.',
      tags: ['wildlife', 'lion', 'ink', 'detail'],
      likesCount: 98,
      averageRating: 4.9,
      totalRatingsCount: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GalleryPost(
      id: 'post_3',
      authorId: 'user_chloe',
      authorName: 'Chloe Zhang',
      authorAvatarUrl: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/56866/garden-rose-red-pink-56866.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Botanical Rose - Watercolor Wash & Pencil',
      description: 'Traced the basic outer petals first, then free-handed the watercolor gradients.',
      tags: ['botanical', 'flower', 'watercolor', 'pencil'],
      likesCount: 215,
      averageRating: 5.0,
      totalRatingsCount: 65,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GalleryPost(
      id: 'post_4',
      authorId: 'user_marcus',
      authorName: 'Marcus Vance',
      authorAvatarUrl: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=150',
      drawingImageUrl: 'https://images.pexels.com/photos/248687/pexels-photo-248687.jpeg?auto=compress&cs=tinysrgb&w=800',
      referenceImageUrl: 'https://images.pexels.com/photos/248687/pexels-photo-248687.jpeg?auto=compress&cs=tinysrgb&w=400',
      title: 'Classic Sports Car Line Drawing',
      description: 'Inverted Sobel line art was super sharp and made the complex perspective easy to trace.',
      tags: ['car', 'perspective', 'ink', 'precision'],
      likesCount: 76,
      averageRating: 4.7,
      totalRatingsCount: 19,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final List<GalleryPost> _posts = [..._initialPosts];

  /// Get all posts with optional filtering and sorting
  static Future<List<GalleryPost>> getPosts({
    String filter = 'trending', // 'trending', 'recent', 'top_rated'
    String searchTag = '',
  }) async {
    List<GalleryPost> list = List.from(_posts);

    if (searchTag.isNotEmpty) {
      list = list.where((p) => p.tags.any((t) => t.toLowerCase().contains(searchTag.toLowerCase())) || p.title.toLowerCase().contains(searchTag.toLowerCase())).toList();
    }

    if (filter == 'trending') {
      list.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    } else if (filter == 'recent') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (filter == 'top_rated') {
      list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    }

    return list;
  }

  /// Create and upload a new artwork post
  static Future<GalleryPost> createPost(GalleryPost post) async {
    _posts.insert(0, post);
    debugPrint('Created new community post: ${post.title}');
    return post;
  }

  /// Toggle like
  static Future<GalleryPost> toggleLike(String postId, String userId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final current = _posts[index];
    final isLiked = current.likedUserIds.contains(userId);
    final updatedLikedIds = List<String>.from(current.likedUserIds);

    if (isLiked) {
      updatedLikedIds.remove(userId);
    } else {
      updatedLikedIds.add(userId);
    }

    final updated = current.copyWith(
      likesCount: updatedLikedIds.length,
      likedUserIds: updatedLikedIds,
    );

    _posts[index] = updated;
    return updated;
  }

  /// Rate artwork from 1 to 5 stars
  static Future<GalleryPost> rateArtwork(String postId, String userId, double rating) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final current = _posts[index];
    final userRatings = Map<String, double>.from(current.userRatings);
    userRatings[userId] = rating;

    final totalRatings = userRatings.length;
    final sum = userRatings.values.fold(0.0, (prev, element) => prev + element);
    final avg = (sum / totalRatings);

    final updated = current.copyWith(
      userRatings: userRatings,
      totalRatingsCount: totalRatings,
      averageRating: double.parse(avg.toStringAsFixed(1)),
    );

    _posts[index] = updated;
    return updated;
  }
}
