import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_craft/core/constants/app_colors.dart';
import 'package:trace_craft/core/widgets/glass_card.dart';

class OpacityControlBar extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onOpacityChanged;
  final VoidCallback onToggleVisibility;
  final bool isVisible;

  const OpacityControlBar({
    super.key,
    required this.opacity,
    required this.onOpacityChanged,
    required this.onToggleVisibility,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Eye Peek Button (Inspect paper vs overlay)
              IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: isVisible ? AppColors.accentCyan : AppColors.textMuted,
                  size: 22,
                ),
                tooltip: isVisible ? 'Hide reference (inspect sketch)' : 'Show reference',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onToggleVisibility();
                },
              ),

              // Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    activeTrackColor: AppColors.primaryLight,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.primary.withValues(alpha: 0.25),
                  ),
                  child: Slider(
                    value: opacity.clamp(0.05, 0.95),
                    min: 0.05,
                    max: 0.95,
                    onChanged: (val) {
                      onOpacityChanged(val);
                    },
                  ),
                ),
              ),

              // Percentage Badge
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Center(
                  child: Text(
                    '${(opacity * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentCyan,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Quick Presets
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPresetChip('25%', 0.25),
                const SizedBox(width: 8),
                _buildPresetChip('45% (Best)', 0.45),
                const SizedBox(width: 8),
                _buildPresetChip('70%', 0.70),
                const SizedBox(width: 8),
                _buildPresetChip('90%', 0.90),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, double value) {
    final isSelected = (opacity - value).abs() < 0.05;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onOpacityChanged(value);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.glassBorder,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
