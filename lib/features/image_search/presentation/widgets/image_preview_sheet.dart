import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/features/image_search/domain/models/search_image.dart';
import 'package:trace_craft/features/tracing/presentation/screens/tracing_screen.dart';

class ImagePreviewSheet extends StatelessWidget {
  final SearchImage image;

  const ImagePreviewSheet({super.key, required this.image});

  static void show(BuildContext context, SearchImage image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      builder: (_) => ImagePreviewSheet(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // High-Res Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: image.originalUrl.isNotEmpty ? image.originalUrl : image.previewUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title & Details
          Text(
            image.title.isNotEmpty ? image.title : '${image.category} Sketch Reference',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Photographer: ${image.photographer}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                ),
                child: Text(
                  image.category,
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TracingScreen(
                    imagePathOrUrl: image.originalUrl.isNotEmpty ? image.originalUrl : image.previewUrl,
                    title: image.title.isNotEmpty ? image.title : 'Tracing ${image.category}',
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.draw_rounded, color: Colors.white),
            label: const Text(
              'Start Tracing (Camera Lucida)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TracingScreen(
                    imagePathOrUrl: image.originalUrl.isNotEmpty ? image.originalUrl : image.previewUrl,
                    title: image.title.isNotEmpty ? image.title : 'Tracing ${image.category}',
                    initialEdgeDetection: true,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.accentCyan),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.auto_fix_high_rounded, color: AppColors.accentCyan),
            label: const Text(
              'Convert to Line Art & Trace',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentCyan),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
