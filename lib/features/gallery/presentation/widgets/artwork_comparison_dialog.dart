import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/features/gallery/domain/models/gallery_post.dart';

class ArtworkComparisonDialog extends StatefulWidget {
  final GalleryPost post;

  const ArtworkComparisonDialog({super.key, required this.post});

  static void show(BuildContext context, GalleryPost post) {
    showDialog(
      context: context,
      builder: (_) => ArtworkComparisonDialog(post: post),
    );
  }

  @override
  State<ArtworkComparisonDialog> createState() => _ArtworkComparisonDialogState();
}

class _ArtworkComparisonDialogState extends State<ArtworkComparisonDialog> {
  double _splitRatio = 0.5; // 0.0 = only reference, 1.0 = only drawing

  @override
  Widget build(BuildContext context) {
    final hasRef = widget.post.referenceImageUrl != null && widget.post.referenceImageUrl!.isNotEmpty;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.compare_rounded, color: AppColors.accentCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (hasRef) ...[
              // Comparison Split View
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Reference image background
                      CachedNetworkImage(
                        imageUrl: widget.post.referenceImageUrl!,
                        fit: BoxFit.cover,
                      ),

                      // User drawing foreground with opacity split
                      Opacity(
                        opacity: _splitRatio,
                        child: CachedNetworkImage(
                          imageUrl: widget.post.drawingImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Scrim tags
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Reference Image', style: TextStyle(fontSize: 10, color: Colors.white70)),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Finished Drawing', style: TextStyle(fontSize: 10, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Blend Slider
              Row(
                children: [
                  const Text('Reference', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Expanded(
                    child: Slider(
                      value: _splitRatio,
                      min: 0.0,
                      max: 1.0,
                      activeColor: AppColors.primaryLight,
                      onChanged: (val) => setState(() => _splitRatio = val),
                    ),
                  ),
                  const Text('Drawing', style: TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                ],
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: widget.post.drawingImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Text(
              widget.post.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
