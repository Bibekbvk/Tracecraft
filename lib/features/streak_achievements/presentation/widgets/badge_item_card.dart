import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';
import 'package:trace_craft/core/widgets/pulsing_badge.dart';
import 'package:trace_craft/features/streak_achievements/domain/models/achievement_badge.dart';

class BadgeItemCard extends StatelessWidget {
  final AchievementBadge badge;
  final bool isUnlocked;
  final int currentProgress;

  const BadgeItemCard({
    super.key,
    required this.badge,
    required this.isUnlocked,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      border: isUnlocked
          ? Border.all(color: badge.badgeColor.withValues(alpha: 0.6), width: 1.5)
          : Border.all(color: AppColors.glassBorder),
      color: isUnlocked
          ? badge.badgeColor.withValues(alpha: 0.08)
          : AppColors.surfaceDark.withValues(alpha: 0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PulsingBadge(
            animate: isUnlocked,
            pulseColor: badge.badgeColor,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? badge.badgeColor.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated,
                border: Border.all(
                  color: isUnlocked ? badge.badgeColor : AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  badge.icon,
                  color: isUnlocked ? badge.badgeColor : AppColors.textMuted,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // Status Badge / Progress
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 10, color: AppColors.accentGreen),
                  SizedBox(width: 4),
                  Text(
                    'UNLOCKED',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (currentProgress / badge.requiredCount).clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceHighlight,
                    color: badge.badgeColor,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$currentProgress / ${badge.requiredCount}',
                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
