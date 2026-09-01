import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trace_craft/models/user_settings_model.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/widgets/app_drawer.dart';
import 'package:trace_craft/widgets/glass_card_widget.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B24),
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            tooltip: 'Open Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF7675), size: 22),
            SizedBox(width: 8),
            Text(
              'Streaks & Trophies',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<Box<UserSettings>>(
        valueListenable: DatabaseService.settingsBox.listenable(),
        builder: (context, box, _) {
          final settings = box.get('current') ?? UserSettings();
          final streakDays = settings.currentStreakDays;
          final totalDone = settings.totalDrawingsCompleted;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO FLAME STREAK CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE17055), Color(0xFFD63031)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD63031).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, size: 52, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$streakDays Day Streak',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        streakDays > 1
                            ? 'You\'re on fire! Keep tracing daily to build muscle memory.'
                            : 'Complete a drawing today to keep your flame burning!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. ARTIST STATS ROW
                Row(
                  children: [
                    Expanded(
                      child: GlassCardWidget(
                        borderRadius: 18,
                        color: const Color(0xFF181B24),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.brush_rounded, color: Color(0xFF00CEC9), size: 24),
                            const SizedBox(height: 12),
                            Text(
                              '$totalDone',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const Text(
                              'Drawings Finished',
                              style: TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCardWidget(
                        borderRadius: 18,
                        color: const Color(0xFF181B24),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.military_tech_rounded, color: Color(0xFFFFB300), size: 24),
                            const SizedBox(height: 12),
                            Text(
                              totalDone >= 10 ? 'Master' : (totalDone >= 3 ? 'Artisan' : 'Novice'),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const Text(
                              'Artist Rank',
                              style: TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 3. TROPHY BADGES SECTION
                const Text(
                  'Achievements & Badges',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),

                _buildBadgeCard(
                  icon: Icons.flag_rounded,
                  iconColor: const Color(0xFF00CEC9),
                  title: 'First Stroke',
                  desc: 'Completed your very first tracing drawing',
                  isUnlocked: totalDone >= 1,
                ),
                _buildBadgeCard(
                  icon: Icons.whatshot_rounded,
                  iconColor: const Color(0xFFFF7675),
                  title: '3-Day Fire',
                  desc: 'Maintained a 3-day consecutive tracing streak',
                  isUnlocked: streakDays >= 3,
                ),
                _buildBadgeCard(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: const Color(0xFFFFB300),
                  title: 'Dedicated Artisan',
                  desc: 'Completed 5 physical drawings on paper',
                  isUnlocked: totalDone >= 5,
                ),
                _buildBadgeCard(
                  icon: Icons.military_tech_rounded,
                  iconColor: const Color(0xFFA29BFE),
                  title: '7-Day Master',
                  desc: 'Drawn 7 days in a row without breaking streak',
                  isUnlocked: streakDays >= 7,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isUnlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181B24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? iconColor.withValues(alpha: 0.4) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? iconColor.withValues(alpha: 0.2) : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? iconColor : Colors.white38,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isUnlocked ? Colors.white : Colors.white60,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CEC9).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'UNLOCKED',
                          style: TextStyle(color: Color(0xFF00CEC9), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
