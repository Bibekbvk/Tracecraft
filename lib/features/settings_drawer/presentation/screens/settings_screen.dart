import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';
import 'package:trace_craft/features/settings_drawer/presentation/controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _pexelsKeyController;
  late TextEditingController _pixabayKeyController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _pexelsKeyController = TextEditingController(text: settings.customPexelsKey);
    _pixabayKeyController = TextEditingController(text: settings.customPixabayKey);
  }

  @override
  void dispose() {
    _pexelsKeyController.dispose();
    _pixabayKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Tracing Canvas Preferences',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Keep Screen Awake'),
                  subtitle: const Text('Prevent display sleep while tracing'),
                  value: settings.enableKeepScreenOn,
                  activeThumbColor: AppColors.primary,
                  onChanged: notifier.toggleKeepScreenOn,
                ),
                const Divider(height: 1, color: AppColors.glassBorder),
                SwitchListTile(
                  title: const Text('Auto-Save Projects'),
                  subtitle: const Text('Save session changes automatically'),
                  value: settings.autoSaveSessions,
                  activeThumbColor: AppColors.primary,
                  onChanged: notifier.toggleAutoSave,
                ),
                const Divider(height: 1, color: AppColors.glassBorder),
                SwitchListTile(
                  title: const Text('Haptic Touch Feedback'),
                  subtitle: const Text('Vibration on lock, flip, and slider ticks'),
                  value: settings.hapticFeedbackEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: notifier.toggleHaptic,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Default Opacity & Proportions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentAmber),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Initial Overlay Opacity'),
                    Text(
                      '${(settings.defaultOpacity * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                    ),
                  ],
                ),
                Slider(
                  value: settings.defaultOpacity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 8,
                  onChanged: notifier.setDefaultOpacity,
                ),
                const Divider(height: 16, color: AppColors.glassBorder),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Default Grid Subdivision'),
                    DropdownButton<int>(
                      value: settings.defaultGridDivisions,
                      dropdownColor: AppColors.surfaceDark,
                      items: const [
                        DropdownMenuItem(value: 2, child: Text('2x2 Grid')),
                        DropdownMenuItem(value: 3, child: Text('3x3 (Rule of Thirds)')),
                        DropdownMenuItem(value: 4, child: Text('4x4 Grid')),
                        DropdownMenuItem(value: 8, child: Text('8x8 Precision')),
                      ],
                      onChanged: (val) {
                        if (val != null) notifier.setDefaultGridDivisions(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Custom API Keys (Optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentPink),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TraceCraft includes free shared keys for Pexels and Pixabay. You can also insert your own personal free developer keys for higher rate limits.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pexelsKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Pexels API Key',
                    hintText: 'Enter Pexels Key',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pixabayKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Pixabay API Key',
                    hintText: 'Enter Pixabay Key',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: () {
                      notifier.setCustomApiKeys(
                        pexelsKey: _pexelsKeyController.text.trim(),
                        pixabayKey: _pixabayKeyController.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API Keys updated successfully!')),
                      );
                    },
                    child: const Text('Save Keys'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
