import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';
import 'package:trace_craft/features/tracing/domain/models/tracing_session.dart';

class ProjectCard extends StatelessWidget {
  final TracingSession session;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.session,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().add_jm().format(session.lastModifiedAt);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _buildThumbnail(),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last edited: $dateStr',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Opacity: ${(session.opacity * 100).toInt()}%',
                        style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (session.isEdgeDetectionEnabled) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Line Art',
                          style: TextStyle(fontSize: 10, color: AppColors.accentCyan, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 36),
                tooltip: 'Resume Tracing',
                onPressed: onResume,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 18),
                tooltip: 'Delete Project',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (session.sourceImagePath.startsWith('http://') || session.sourceImagePath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: session.sourceImagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: AppColors.surfaceHighlight),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image_rounded),
      );
    } else {
      return Image.file(
        File(session.sourceImagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded),
      );
    }
  }
}
