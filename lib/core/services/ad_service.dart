import 'package:flutter/foundation.dart';

class AdService {
  static bool isInitialized = false;

  static Future<void> init() async {
    isInitialized = true;
    debugPrint('AdService initialized (Ready for AdMob banner, interstitial, & rewarded): $isInitialized');
  }

  /// Displays an interstitial ad (e.g. after saving or completing a drawing session)
  static Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    debugPrint('Showing Interstitial Ad...');
    await Future.delayed(const Duration(milliseconds: 300));
    onDismissed?.call();
  }

  /// Displays a rewarded ad (e.g. to unlock extra sketch filters or premium high-res models)
  static Future<bool> showRewardedAd({required VoidCallback onRewardEarned}) async {
    debugPrint('Showing Rewarded Ad...');
    await Future.delayed(const Duration(milliseconds: 400));
    onRewardEarned();
    return true;
  }
}
