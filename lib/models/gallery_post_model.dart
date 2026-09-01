class GalleryPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String drawingImageUrl; // Finished artwork photo/scan in Firebase Storage
  final String? referenceImageUrl; // Original reference image
  final String title;
  final String description;
  final List<String> tags;
  final int likesCount;
  final List<String> likedUserIds;
  final double averageRating; // 1.0 to 5.0
  final int totalRatingsCount;
  final Map<String, double> userRatings; // Map<UserId, Rating>
  final DateTime createdAt;

  GalleryPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.drawingImageUrl,
    this.referenceImageUrl,
    required this.title,
    this.description = '',
    this.tags = const [],
    this.likesCount = 0,
    this.likedUserIds = const [],
    this.averageRating = 0.0,
    this.totalRatingsCount = 0,
    this.userRatings = const {},
    required this.createdAt,
  });

  GalleryPost copyWith({
    String? title,
    String? description,
    List<String>? tags,
    int? likesCount,
    List<String>? likedUserIds,
    double? averageRating,
    int? totalRatingsCount,
    Map<String, double>? userRatings,
  }) {
    return GalleryPost(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      drawingImageUrl: drawingImageUrl,
      referenceImageUrl: referenceImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      averageRating: averageRating ?? this.averageRating,
      totalRatingsCount: totalRatingsCount ?? this.totalRatingsCount,
      userRatings: userRatings ?? this.userRatings,
      createdAt: createdAt,
    );
  }

  factory GalleryPost.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return GalleryPost(
      id: documentId ?? json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Artist',
      authorAvatarUrl: json['authorAvatarUrl'],
      drawingImageUrl: json['drawingImageUrl'] ?? '',
      referenceImageUrl: json['referenceImageUrl'],
      title: json['title'] ?? 'Artwork',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      likedUserIds: List<String>.from(json['likedUserIds'] ?? []),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatingsCount: json['totalRatingsCount'] ?? 0,
      userRatings: (json['userRatings'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
              : DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'drawingImageUrl': drawingImageUrl,
      'referenceImageUrl': referenceImageUrl,
      'title': title,
      'description': description,
      'tags': tags,
      'likesCount': likesCount,
      'likedUserIds': likedUserIds,
      'averageRating': averageRating,
      'totalRatingsCount': totalRatingsCount,
      'userRatings': userRatings,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
