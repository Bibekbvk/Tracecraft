import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/database/hive_boxes.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';
import 'package:trace_craft/features/settings_drawer/presentation/screens/app_drawer.dart';
import 'package:trace_craft/features/streak_achievements/domain/models/achievement_badge.dart';
import 'package:trace_craft/features/streak_achievements/presentation/widgets/badge_item_card.dart';

class StreakAchievementsScreen extends StatelessWidget {
  const StreakAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Streaks & Achievements'),
      ),
      body: ValueListenableBuilder<Box<StreakRecord>>(
        valueListenable: HiveDatabase.streakBox.listenable(),
        builder: (context, box, _) {
          final streak = HiveDatabase.getStreakRecord();
          final totalCompleted = streak.totalDrawingsCompleted;
          final currentStreak = streak.currentStreakDays;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Hero Glowing Streak Counter
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE17055), Color(0xFFD63031)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE17055).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$currentStreak',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'DAY STREAK',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Keep drawing daily to form muscle memory and refine penmanship!',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded, color: AppColors.accentAmber, size: 18),
                              SizedBox(width: 6),
                              Text('Best Streak', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${streak.maxStreakDays} Days',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.palette_rounded, color: AppColors.accentCyan, size: 18),
                              SizedBox(width: 6),
                              Text('Completed Art', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$totalCompleted Artworks',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Artist Badges & Trophies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Badges Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AchievementBadge.allBadges.length,
                itemBuilder: (context, index) {
                  final badge = AchievementBadge.allBadges[index];
                  bool isUnlocked = false;
                  int progress = 0;

                  if (badge.category == 'streak') {
                    progress = streak.maxStreakDays;
                    isUnlocked = streak.maxStreakDays >= badge.requiredCount;
                  } else if (badge.category == 'drawings') {
                    progress = totalCompleted;
                    isUnlocked = totalCompleted >= badge.requiredCount;
                  } else {
                    progress = totalCompleted > 0 ? 1 : 0;
                    isUnlocked = progress >= badge.requiredCount;
                  }

                  return BadgeItemCard(
                    badge: badge,
                    isUnlocked: isUnlocked,
                    currentProgress: progress,
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
