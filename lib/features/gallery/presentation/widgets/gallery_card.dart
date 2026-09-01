import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';
import 'package:trace_craft/features/gallery/domain/models/gallery_post.dart';
import 'package:trace_craft/features/gallery/presentation/widgets/artwork_comparison_dialog.dart';

class GalleryCard extends StatelessWidget {
  final GalleryPost post;
  final String currentUserId;
  final VoidCallback onLikeToggle;
  final ValueChanged<double> onRatingSubmit;

  const GalleryCard({
    super.key,
    required this.post,
    this.currentUserId = 'my_user_id',
    required this.onLikeToggle,
    required this.onRatingSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.likedUserIds.contains(currentUserId);
    final userRating = post.userRatings[currentUserId] ?? post.averageRating;
    final timeStr = DateFormat.yMMMd().format(post.createdAt);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                backgroundImage: post.authorAvatarUrl != null
                    ? CachedNetworkImageProvider(post.authorAvatarUrl!)
                    : null,
                child: post.authorAvatarUrl == null
                    ? Text(
                        post.authorName.isNotEmpty ? post.authorName[0] : 'A',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (post.referenceImageUrl != null && post.referenceImageUrl!.isNotEmpty)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.compare_rounded, size: 16, color: AppColors.accentCyan),
                  label: const Text('Compare', style: TextStyle(fontSize: 11, color: AppColors.accentCyan)),
                  onPressed: () => ArtworkComparisonDialog.show(context, post),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Artwork Image
          GestureDetector(
            onTap: () => ArtworkComparisonDialog.show(context, post),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: CachedNetworkImage(
                  imageUrl: post.drawingImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title & Description
          Text(
            post.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (post.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              post.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),

          // Tags
          if (post.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.glassBorder),
          const SizedBox(height: 8),

          // Interactive Likes & Ratings
          Row(
            children: [
              // Like Button
              InkWell(
                onTap: onLikeToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? AppColors.accentPink : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isLiked ? AppColors.accentPink : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // 5-Star Rating Bar
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 18,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: AppColors.accentAmber,
                    ),
                    onRatingUpdate: onRatingSubmit,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.averageRating} (${post.totalRatingsCount})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentAmber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
