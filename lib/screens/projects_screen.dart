import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:trace_craft/models/session_model.dart';
import 'package:trace_craft/models/user_settings_model.dart';
import 'package:trace_craft/screens/tracing_screen.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/widgets/glass_card_widget.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
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
            Icon(Icons.folder_special_rounded, color: Color(0xFF00CEC9), size: 22),
            SizedBox(width: 8),
            Text(
              'My Tracing Projects',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<Box<UserSettings>>(
        valueListenable: DatabaseService.settingsBox.listenable(),
        builder: (context, settingsBox, _) {
          final settings = settingsBox.get('current') ?? UserSettings();

          return Column(
            children: [
              // 1. STREAK & ACHIEVEMENT BADGE ROW
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildStreakBadgeRow(settings),
              ),

              // 2. SAVED SESSIONS LIST
              Expanded(
                child: ValueListenableBuilder<Box<Session>>(
                  valueListenable: DatabaseService.sessionsBox.listenable(),
                  builder: (context, box, _) {
                    final sessions = box.values.toList().cast<Session>();
                    sessions.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));

                    if (sessions.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return _buildProjectCard(context, session);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Top Small Badge Row for Streaks and Completed Drawings
  Widget _buildStreakBadgeRow(UserSettings settings) {
    final streakDays = settings.currentStreakDays;
    final totalDone = settings.totalDrawingsCompleted;

    String rankBadge = 'Novice';
    if (totalDone >= 10 || streakDays >= 7) {
      rankBadge = 'Master';
    } else if (totalDone >= 3 || streakDays >= 3) {
      rankBadge = 'Artisan';
    }

    return GlassCardWidget(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF181B24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Daily Streak Badge
          _buildBadgeItem(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF7675),
            title: '$streakDays ${streakDays == 1 ? 'Day' : 'Days'}',
            subtitle: 'Streak',
          ),
          Container(height: 28, width: 1, color: Colors.white12),

          // Total Completed Badge
          _buildBadgeItem(
            icon: Icons.brush_rounded,
            iconColor: const Color(0xFF00CEC9),
            title: '$totalDone Done',
            subtitle: 'Drawings',
          ),
          Container(height: 28, width: 1, color: Colors.white12),

          // Artist Rank Badge
          _buildBadgeItem(
            icon: Icons.military_tech_rounded,
            iconColor: const Color(0xFFFFB300),
            title: rankBadge,
            subtitle: 'Level',
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  /// Individual Project Card with Thumbnail, Last-Edited, Badges & Resume
  Widget _buildProjectCard(BuildContext context, Session session) {
    final dateStr = DateFormat.yMMMd().add_jm().format(session.lastModifiedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181B24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: InkWell(
        onTap: () => _resumeSession(context, session),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Project Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: _buildThumbnailImage(session.sourceImagePath),
                ),
              ),
              const SizedBox(width: 14),

              // Info & Progress Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edited: $dateStr',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Opacity badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA29BFE).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Opacity: ${(session.opacity * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10, color: Color(0xFFA29BFE), fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Line Art badge
                        if (session.isEdgeDetectionEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00CEC9).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Line Art',
                              style: TextStyle(fontSize: 10, color: Color(0xFF00CEC9), fontWeight: FontWeight.bold),
                            ),
                          ),

                        // Locked badge
                        if (session.isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Locked',
                              style: TextStyle(fontSize: 10, color: Color(0xFFFFB300), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Resume Button & Delete Menu
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF6C5CE7), size: 36),
                    tooltip: 'Resume Tracing',
                    onPressed: () => _resumeSession(context, session),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                    tooltip: 'Delete Project',
                    onPressed: () => _confirmDelete(context, session),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: pathOrUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: const Color(0xFF222634)),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image_rounded, color: Colors.white24),
      );
    } else {
      return Image.file(
        File(pathOrUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded, color: Colors.white24),
      );
    }
  }

  /// Resumes tracing session with exact Matrix4 transform and filters
  void _resumeSession(BuildContext context, Session session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TracingScreen(
          imagePathOrUrl: session.sourceImagePath,
          title: session.title,
          initialSession: session,
        ),
      ),
    );
  }

  /// Confirm and delete session from Hive
  Future<void> _confirmDelete(BuildContext context, Session session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181B24),
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF7675)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.deleteSession(session.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${session.title}" deleted.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_edu_rounded, size: 54, color: Color(0xFFA29BFE)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Saved Projects Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select any sketch from the Discover tab to start tracing. Your progress, zoom, and opacity are saved automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
