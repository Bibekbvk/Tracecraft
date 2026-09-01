import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';

class TracingControlPanel extends StatelessWidget {
  final bool isLocked;
  final VoidCallback onToggleLock;
  final bool isTorchOn;
  final VoidCallback onToggleTorch;
  final bool isEdgeDetectionEnabled;
  final VoidCallback onOpenEdgeTuning;
  final bool isGridEnabled;
  final VoidCallback onToggleGrid;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;
  final VoidCallback onResetTransform;
  final VoidCallback onSaveSession;
  final VoidCallback onFinishArtwork;

  const TracingControlPanel({
    super.key,
    required this.isLocked,
    required this.onToggleLock,
    required this.isTorchOn,
    required this.onToggleTorch,
    required this.isEdgeDetectionEnabled,
    required this.onOpenEdgeTuning,
    required this.isGridEnabled,
    required this.onToggleGrid,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
    required this.onResetTransform,
    required this.onSaveSession,
    required this.onFinishArtwork,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Lock Position Floating Button (Huge Priority Tool)
        GlassCard(
          borderRadius: 30,
          padding: const EdgeInsets.all(4),
          color: isLocked ? AppColors.accentAmber.withValues(alpha: 0.3) : null,
          border: isLocked
              ? Border.all(color: AppColors.accentAmber, width: 1.5)
              : null,
          child: IconButton(
            icon: Icon(
              isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: isLocked ? AppColors.accentAmber : Colors.white70,
              size: 24,
            ),
            tooltip: isLocked ? 'Unlock transformation' : 'Lock position (prevents accidental movement)',
            onPressed: () {
              HapticFeedback.mediumImpact();
              onToggleLock();
            },
          ),
        ),
        const SizedBox(height: 10),

        // Vertical Control Strip
        GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flashlight / Torch
              _buildToolButton(
                icon: isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                tooltip: 'Flashlight',
                isActive: isTorchOn,
                activeColor: AppColors.accentAmber,
                onTap: onToggleTorch,
              ),
              const SizedBox(height: 6),

              // Edge Detection / Line Art
              _buildToolButton(
                icon: Icons.auto_fix_high_rounded,
                tooltip: 'Line Art / Edge Filter',
                isActive: isEdgeDetectionEnabled,
                activeColor: AppColors.accentCyan,
                onTap: onOpenEdgeTuning,
              ),
              const SizedBox(height: 6),

              // Grid Guide
              _buildToolButton(
                icon: Icons.grid_4x4_rounded,
                tooltip: 'Proportion Grid',
                isActive: isGridEnabled,
                activeColor: AppColors.accentPink,
                onTap: onToggleGrid,
              ),
              const SizedBox(height: 6),

              // Horizontal Flip
              _buildToolButton(
                icon: Icons.flip_rounded,
                tooltip: 'Flip Horizontal',
                isActive: false,
                onTap: onFlipHorizontal,
              ),
              const SizedBox(height: 6),

              // Reset Transform
              _buildToolButton(
                icon: Icons.restart_alt_rounded,
                tooltip: 'Reset Scale & Pan',
                isActive: false,
                onTap: onResetTransform,
              ),
              const SizedBox(height: 6),

              // Save Session
              _buildToolButton(
                icon: Icons.bookmark_add_rounded,
                tooltip: 'Save Project State',
                isActive: false,
                onTap: onSaveSession,
              ),
              const Divider(height: 16, indent: 6, endIndent: 6, color: AppColors.glassBorder),

              // Finish Artwork & Export/Post
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentGreen, Color(0xFF00CEC9)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                  tooltip: 'Finish & Share Artwork',
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    onFinishArtwork();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    Color activeColor = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.25) : Colors.transparent,
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: activeColor, width: 1.2) : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive ? activeColor : AppColors.textSecondary,
          size: 20,
        ),
        tooltip: tooltip,
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }
}
