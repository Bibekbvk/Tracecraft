import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/constants/app_constants.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About TraceCraft')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accentCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.draw_rounded, size: 48, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppConstants.appTagline,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Mission',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TraceCraft empowers artists, students, illustrators, and beginners to master proportion, line confidence, and hand-eye coordination by merging historical camera lucida optics with cutting-edge AR mobile technology.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GlassCard(
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Image Providers',
                  value: 'Pexels & Pixabay APIs (Royalty-free)',
                ),
                const Divider(height: 16, color: AppColors.glassBorder),
                _buildInfoTile(
                  icon: Icons.storage_rounded,
                  title: 'Storage & Offline Engine',
                  value: 'Hive Local Key-Value Store',
                ),
                const Divider(height: 16, color: AppColors.glassBorder),
                _buildInfoTile(
                  icon: Icons.filter_vintage_rounded,
                  title: 'Outline & Line Art Filter',
                  value: 'Sobel High-Pass Gradient Isolate',
                ),
                const Divider(height: 16, color: AppColors.glassBorder),
                _buildInfoTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy',
                  value: '100% Offline Processing',
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
