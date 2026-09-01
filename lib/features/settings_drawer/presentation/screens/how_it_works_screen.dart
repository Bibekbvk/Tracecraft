import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Lucida Tutorial'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Camera Lucida Effect',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Trace anything with optical precision',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'In the 19th century, master artists used optical prisms called "Camera Lucida" to overlay a subject onto paper. TraceCraft brings this classic technique into the modern AR era!',
                  style: TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '3 Easy Steps to Master Tracing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          _buildStepCard(
            context,
            stepNumber: '1',
            icon: Icons.phone_android_rounded,
            title: 'Mount Your Phone on a Stand',
            description:
                'Place a blank sheet of paper on your desk. Prop your phone on a tripod, mug, or phone stand about 20–30 cm above the paper, with the rear camera facing downward.',
            color: AppColors.accentCyan,
          ),
          const SizedBox(height: 12),

          _buildStepCard(
            context,
            stepNumber: '2',
            icon: Icons.tune_rounded,
            title: 'Position, Scale & Adjust Opacity',
            description:
                'Pick a reference image or photo. Pinch to zoom and pan the image over the paper area. Use the Opacity Slider (usually 40–50% is ideal) so you can clearly see both your pencil tip and the outline.',
            color: AppColors.accentAmber,
          ),
          const SizedBox(height: 12),

          _buildStepCard(
            context,
            stepNumber: '3',
            icon: Icons.lock_outline_rounded,
            title: 'Lock Position & Trace Line-Art',
            description:
                'Tap the Lock icon to freeze the image in place. Turn on Edge-Detection (Outline Mode) to convert photos into crisp sketch lines, then trace directly with your pen/pencil!',
            color: AppColors.accentGreen,
          ),

          const SizedBox(height: 24),
          const Text(
            'Pro Drawing Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GlassCard(
            child: Column(
              children: [
                _buildTipRow(
                  icon: Icons.flash_on_rounded,
                  title: 'Good Lighting',
                  subtitle: 'Use a bright desk lamp or tap the Flashlight button in TraceCraft for maximum paper clarity.',
                ),
                const Divider(height: 20, color: AppColors.glassBorder),
                _buildTipRow(
                  icon: Icons.grid_4x4_rounded,
                  title: 'Use the Grid Guide',
                  subtitle: 'Toggle the Grid overlay to verify proportions and angles for complex portraits and cars.',
                ),
                const Divider(height: 20, color: AppColors.glassBorder),
                _buildTipRow(
                  icon: Icons.flip_rounded,
                  title: 'Mirror & Invert',
                  subtitle: 'Flip horizontally if you are left-handed or checking facial symmetry.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STEP $stepNumber',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
