import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace_craft/screens/main_shell_screen.dart';
import 'package:trace_craft/screens/onboarding_tutorial_screen.dart';
import 'package:trace_craft/services/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _brandController;
  late AnimationController _floodProgressController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();

    // 1. Brand Logo Entrance Animation (1000ms)
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeIn),
    );

    _brandController.forward();

    // 2. Bi-Directional Flood Water Progress Bar (Exact 3-second duration: 3000ms)
    _floodProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _floodProgressController.forward();

    // 3. Exactly 3-second timer before navigating to the next screen
    _splashTimer = Timer(const Duration(milliseconds: 3000), _navigateToNext);
  }

  void _navigateToNext() {
    if (!mounted) return;
    final settings = DatabaseService.getUserSettings();
    if (settings.showOnboardingTutorial) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingTutorialScreen(isFromDrawer: false)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _brandController.dispose();
    _floodProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Stack(
        children: [
          // Subtle Ambient Background Glows
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00CEC9).withValues(alpha: 0.16),
              ),
            ),
          ),

          // Central Brand & Water Flood Progress
          Center(
            child: AnimatedBuilder(
              animation: _brandController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Brand Icon
                        Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.draw_rounded, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 26),

                        // Title
                        Text(
                          'TraceCraft',
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'Camera Lucida Drawing Assistant',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF00CEC9),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 54),

                        // Bi-Directional Water Flood Progress Bar
                        AnimatedBuilder(
                          animation: _floodProgressController,
                          builder: (context, _) {
                            final progress = _floodProgressController.value;
                            return Column(
                              children: [
                                // Center-Outward Water Flood Bar
                                SizedBox(
                                  width: 260,
                                  height: 8,
                                  child: CustomPaint(
                                    painter: _WaterFloodProgressPainter(progress: progress),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Progress percentage / loading status
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF00CEC9),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Loading Optical Tracing Engine... ${(progress * 100).toInt()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Version Tag
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'TraceCraft v1.0.0 • Hardware-Accelerated AR',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter that renders water flowing outwards from the center to both left and right simultaneously
class _WaterFloodProgressPainter extends CustomPainter {
  final double progress;

  _WaterFloodProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background Track (Dark Glass Pill)
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(trackRRect, bgPaint);

    if (progress <= 0.0) return;

    // 2. Calculate symmetrical flood expansion from center (x = size.width / 2)
    final centerX = size.width / 2;
    final halfWidth = (size.width / 2) * progress.clamp(0.0, 1.0);

    final leftX = centerX - halfWidth;
    final rightX = centerX + halfWidth;

    final floodRect = Rect.fromLTRB(leftX, 0, rightX, size.height);
    final floodRRect = RRect.fromRectAndRadius(floodRect, Radius.circular(size.height / 2));

    // 3. Flood Water Gradient (Electric Cyan -> Blue -> Violet)
    final waterGradient = LinearGradient(
      colors: const [
        Color(0xFF00CEC9), // Left wave front
        Color(0xFF74B9FF), // Center surge
        Color(0xFF6C5CE7), // Deep water
        Color(0xFF74B9FF), // Center surge
        Color(0xFF00CEC9), // Right wave front
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final floodPaint = Paint()
      ..shader = waterGradient.createShader(floodRect)
      ..style = PaintingStyle.fill;

    // Outer Glow Shadow
    final glowPaint = Paint()
      ..color = const Color(0xFF00CEC9).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(floodRRect, glowPaint);
    canvas.drawRRect(floodRRect, floodPaint);

    // 4. Wave Crest Water Droplets / Highlights at the expanding tips
    final crestPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Left flood crest point
    if (leftX > 0) {
      canvas.drawCircle(Offset(leftX + (size.height / 2), size.height / 2), size.height * 0.35, crestPaint);
    }
    // Right flood crest point
    if (rightX < size.width) {
      canvas.drawCircle(Offset(rightX - (size.height / 2), size.height / 2), size.height * 0.35, crestPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterFloodProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
