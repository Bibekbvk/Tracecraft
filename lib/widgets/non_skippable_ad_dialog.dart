import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace_craft/services/ad_service.dart';

/// 10-Second Non-Skippable Video / Interstitial Ad Dialog
/// Enforces a strict 10-second viewing requirement before allowing dismissal
class NonSkippableAdDialog extends StatefulWidget {
  final String title;
  final String sponsorName;
  final VoidCallback? onRewardEarned;

  const NonSkippableAdDialog({
    super.key,
    this.title = 'Special Sponsor Message',
    this.sponsorName = 'TraceCraft Pro Creative Studio',
    this.onRewardEarned,
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'Sponsored Video Ad',
    String sponsorName = 'TraceCraft Creative Studio',
    VoidCallback? onRewardEarned,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NonSkippableAdDialog(
        title: title,
        sponsorName: sponsorName,
        onRewardEarned: onRewardEarned,
      ),
    );
    return result ?? false;
  }

  @override
  State<NonSkippableAdDialog> createState() => _NonSkippableAdDialogState();
}

class _NonSkippableAdDialogState extends State<NonSkippableAdDialog> with SingleTickerProviderStateMixin {
  int _secondsRemaining = 10;
  Timer? _countdownTimer;
  bool _canSkip = false;
  late AnimationController _progressController;

  final List<Map<String, dynamic>> _sampleAdContents = [
    {
      'title': 'Master High-Precision AR Sketching',
      'tagline': 'Unlock 50+ New Shading & Perspective Guides',
      'cta': 'Learn More',
      'icon': Icons.palette_rounded,
      'gradient': [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
      'badge': 'PREMIUM ART TOOLS',
    },
    {
      'title': 'Ultra-Clear Optical Trace Projection',
      'tagline': 'Zero distortion with hardware-accelerated filters',
      'cta': 'Get Started',
      'icon': Icons.auto_awesome_rounded,
      'gradient': [Color(0xFFFF7675), Color(0xFF6C5CE7)],
      'badge': 'FEATURED SPONSOR',
    },
    {
      'title': 'TraceCraft Pro Cloud Sync',
      'tagline': 'Backup drawings across all your Android devices',
      'cta': 'Explore Pro',
      'icon': Icons.cloud_done_rounded,
      'gradient': [Color(0xFF00B894), Color(0xFF0984E3)],
      'badge': 'SPONSORED PARTNER',
    },
  ];

  late Map<String, dynamic> _currentAd;

  @override
  void initState() {
    super.initState();
    _currentAd = (_sampleAdContents..shuffle()).first;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canSkip = true;
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _onClose() {
    if (!_canSkip) return;
    HapticFeedback.selectionClick();
    AdService.grant24HourAdFree();
    widget.onRewardEarned?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = _currentAd['gradient'] as List<Color>;

    return PopScope(
      canPop: _canSkip,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141720),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with Timer & Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF181B24),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _currentAd['badge'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ),
                    const Spacer(),
                    // 10s Countdown Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _canSkip ? const Color(0xFF00B894) : Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _canSkip ? const Color(0xFF55EFC4) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _canSkip ? Icons.check_circle_rounded : Icons.timer_rounded,
                            size: 14,
                            color: _canSkip ? Colors.white : const Color(0xFFFF7675),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _canSkip ? 'Reward Ready' : 'Ad ends in ${_secondsRemaining}s',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close / Dismiss Button
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: _canSkip ? Colors.white : Colors.white24,
                        size: 20,
                      ),
                      tooltip: _canSkip ? 'Close Ad' : 'Please wait 10 seconds',
                      onPressed: _canSkip ? _onClose : null,
                    ),
                  ],
                ),
              ),

              // 10-Second Linear Progress Bar
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _canSkip ? const Color(0xFF00B894) : const Color(0xFF6C5CE7),
                    ),
                    minHeight: 4,
                  );
                },
              ),

              // Main Video / Sponsor Showcase Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Video Ad Simulation Frame
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _currentAd['icon'] as IconData,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _currentAd['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Non-skippable overlay water-mark
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Sponsored Video Ad (10s)',
                                style: TextStyle(color: Colors.white70, fontSize: 9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle / Tagline
                    Text(
                      _currentAd['tagline'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Button (Active only after 10 seconds)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _canSkip ? const Color(0xFF00B894) : Colors.white12,
                          foregroundColor: _canSkip ? Colors.white : Colors.white38,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _canSkip ? _onClose : null,
                        icon: Icon(
                          _canSkip ? Icons.check_circle_rounded : Icons.lock_clock_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _canSkip ? 'Claim Reward & Continue Drawing ✨' : 'Ad playing (wait ${_secondsRemaining}s)...',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
