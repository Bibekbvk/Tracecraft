import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/providers/settings_provider.dart';
import 'package:trace_craft/screens/onboarding_tutorial_screen.dart';
import 'package:trace_craft/services/database_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _pexelsKeyController;

  @override
  void initState() {
    super.initState();
    final settings = DatabaseService.getUserSettings();
    _pexelsKeyController = TextEditingController(text: settings.customPexelsKey);
  }

  @override
  void dispose() {
    _pexelsKeyController.dispose();
    super.dispose();
  }

  void _saveCustomKey() {
    final settings = DatabaseService.getUserSettings();
    final updated = settings.copyWith(customPexelsKey: _pexelsKeyController.text.trim());
    DatabaseService.saveUserSettings(updated);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom Pexels API Key saved.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B24),
        title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Tracing Canvas
          _buildSectionHeader('Tracing Canvas Preferences'),
          const SizedBox(height: 10),
          _buildCard([
            SwitchListTile(
              secondary: const Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFB300)),
              title: const Text('Keep Screen Awake', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: const Text('Prevent display sleep while tracing on paper', style: TextStyle(color: Colors.white60, fontSize: 12)),
              value: settings.enableKeepScreenOn,
              activeTrackColor: const Color(0xFF6C5CE7),
              onChanged: (val) {
                ref.read(settingsProvider.notifier).setKeepScreenOn(val);
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.opacity_rounded, color: Color(0xFF00CEC9)),
              title: const Text('Default Starting Opacity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Current: ${(settings.defaultOpacity * 100).toInt()}%',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              trailing: SizedBox(
                width: 140,
                child: Slider(
                  value: settings.defaultOpacity,
                  min: 0.1,
                  max: 0.9,
                  activeColor: const Color(0xFF6C5CE7),
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setOpacity(val);
                  },
                ),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Section: API Keys
          _buildSectionHeader('API Key Integration'),
          const SizedBox(height: 10),
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Pexels API Key',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your free key to increase rate limits for search photos.',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pexelsKeyController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Paste Pexels API Key',
                            hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                        onPressed: _saveCustomKey,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Section: Tutorials & Guides
          _buildSectionHeader('Guides & Learning'),
          const SizedBox(height: 10),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.school_rounded, color: Color(0xFFA29BFE)),
              title: const Text('Replay Onboarding Tutorial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: const Text('View the 4-step setup guide', style: TextStyle(color: Colors.white60, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingTutorialScreen(isFromDrawer: true),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00CEC9)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181B24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: children),
    );
  }
}
