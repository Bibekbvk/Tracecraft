import 'package:flutter/material.dart';

class OpacitySliderWidget extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onOpacityChanged;

  const OpacitySliderWidget({
    super.key,
    required this.opacity,
    required this.onOpacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: opacity.clamp(0.05, 0.95),
      min: 0.05,
      max: 0.95,
      onChanged: onOpacityChanged,
    );
  }
}
