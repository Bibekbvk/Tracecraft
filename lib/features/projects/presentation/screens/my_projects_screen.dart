import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/database/hive_boxes.dart';
import 'package:trace_craft/features/projects/presentation/widgets/project_card.dart';
import 'package:trace_craft/features/settings_drawer/presentation/screens/app_drawer.dart';
import 'package:trace_craft/features/tracing/domain/models/tracing_session.dart';
import 'package:trace_craft/features/tracing/presentation/screens/tracing_screen.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My Tracing Projects'),
      ),
      body: ValueListenableBuilder<Box<TracingSession>>(
        valueListenable: HiveDatabase.sessionsBox.listenable(),
        builder: (context, box, _) {
          final sessions = box.values.toList().cast<TracingSession>();
          // Sort by latest modified
          sessions.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));

          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_edu_rounded, size: 54, color: AppColors.primaryLight),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Saved Projects Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose any sketch or photo from the Discover tab and start tracing to save your progress here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ProjectCard(
                session: session,
                onResume: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TracingScreen(
                        imagePathOrUrl: session.sourceImagePath,
                        title: session.title,
                        existingSession: session,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Project?'),
                      content: Text('Are you sure you want to delete "${session.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await box.delete(session.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
