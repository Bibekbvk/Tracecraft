import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_craft/screens/auth_screen.dart';
import 'package:trace_craft/services/database_service.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  final bool isFromDrawer;

  const OnboardingTutorialScreen({super.key, this.isFromDrawer = false});

  @override
  State<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialSlide> _slides = const [
    TutorialSlide(
      icon: Icons.phone_android_rounded,
      iconColor: Color(0xFF6C5CE7),
      title: 'Mount Over Paper',
      subtitle: 'Position your phone on a cup, stand, or clamp facing down toward your blank sheet of drawing paper.',
      badgeText: 'Step 1: Setup',
    ),
    TutorialSlide(
      icon: Icons.layers_rounded,
      iconColor: Color(0xFF00CEC9),
      title: 'Overlay & Adjust Opacity',
      subtitle: 'Pick any reference sketch and adjust the live transparency slider so you can see both the photo and your physical paper.',
      badgeText: 'Step 2: Calibrate',
    ),
    TutorialSlide(
      icon: Icons.draw_rounded,
      iconColor: Color(0xFFFF7675),
      title: 'Trace with Pen or Pencil',
      subtitle: 'Look at the phone screen and guide your hand to trace exact contours, angles, and shading directly onto your paper.',
      badgeText: 'Step 3: Draw',
    ),
    TutorialSlide(
      icon: Icons.auto_fix_high_rounded,
      iconColor: Color(0xFFFFB300),
      title: 'Pro Tools & Community',
      subtitle: 'Turn on Sobel line-art filtering, proportion grid guides, freeze transform with Lock, and share your finished artwork!',
      badgeText: 'Step 4: Master',
    ),
  ];

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final settings = DatabaseService.getUserSettings();
    final updated = settings.copyWith(showOnboardingTutorial: false);
    await DatabaseService.saveUserSettings(updated);

    if (mounted) {
      if (widget.isFromDrawer) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen(isFromDrawer: false)),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.isFromDrawer)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 48),

                  // Page dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF6C5CE7) : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip', style: TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
            ),

            // Carousel PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: slide.iconColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: slide.iconColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            slide.badgeText,
                            style: TextStyle(
                              color: slide.iconColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                slide.iconColor.withValues(alpha: 0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181B24),
                              shape: BoxShape.circle,
                              border: Border.all(color: slide.iconColor.withValues(alpha: 0.3), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: slide.iconColor.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(slide.icon, color: slide.iconColor, size: 68),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Start Tracing Now 🚀' : 'Next',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialSlide {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badgeText;

  const TutorialSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
  });
}
