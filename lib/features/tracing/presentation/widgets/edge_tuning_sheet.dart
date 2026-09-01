import 'package:flutter/material.dart';
import 'package:trace_craft/core/constants/app_colors.dart';

class EdgeTuningSheet extends StatefulWidget {
  final bool isEdgeEnabled;
  final double currentThreshold;
  final bool isInverted;
  final Function(bool enabled, double threshold, bool invert) onApply;

  const EdgeTuningSheet({
    super.key,
    required this.isEdgeEnabled,
    required this.currentThreshold,
    this.isInverted = true,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    required bool isEdgeEnabled,
    required double currentThreshold,
    bool isInverted = true,
    required Function(bool enabled, double threshold, bool invert) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EdgeTuningSheet(
        isEdgeEnabled: isEdgeEnabled,
        currentThreshold: currentThreshold,
        isInverted: isInverted,
        onApply: onApply,
      ),
    );
  }

  @override
  State<EdgeTuningSheet> createState() => _EdgeTuningSheetState();
}

class _EdgeTuningSheetState extends State<EdgeTuningSheet> {
  late bool _enabled;
  late double _threshold;
  late bool _invert;

  @override
  void initState() {
    super.initState();
    _enabled = widget.isEdgeEnabled;
    _threshold = widget.currentThreshold;
    _invert = widget.isInverted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_fix_high_rounded, color: AppColors.accentCyan, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Line-Art & Edge Detection',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Isolates contours into a clean tracing outline',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _enabled,
                activeThumbColor: AppColors.accentCyan,
                onChanged: (val) {
                  setState(() => _enabled = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_enabled) ...[
            const Text(
              'Stroke Outline Sensitivity',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Row(
              children: [
                const Icon(Icons.grain_rounded, size: 16, color: AppColors.textMuted),
                Expanded(
                  child: Slider(
                    value: _threshold,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: AppColors.accentCyan,
                    onChanged: (val) {
                      setState(() => _threshold = val);
                    },
                  ),
                ),
                Text(
                  '${(_threshold * 10).toInt()}/10',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pencil Mode (Dark Lines on Light)', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Best for tracing on standard white paper', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              value: _invert,
              activeThumbColor: AppColors.accentCyan,
              onChanged: (val) => setState(() => _invert = val),
            ),
            const SizedBox(height: 16),
          ],

          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(_enabled, _threshold, _invert);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentCyan,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Apply Filter Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
