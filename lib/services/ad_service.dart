import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:trace_craft/services/database_service.dart';

class AdService {
  static bool isInitialized = false;

  // Track session saves for every 3rd save interstitial
  static int _sessionSaveCounter = 0;
  static const int sessionSavesBeforeInterstitial = 3;

  // Pre-loaded ad instances
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;

  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool _isRewardedLoading = false;

  // Set to true when releasing to Google Play / App Store with your real AdMob Unit IDs
  static bool useProductionAds = true;

  // Real Production Ad Unit IDs (replace with your AdMob Console IDs)
  static const String prodAndroidBannerId = 'ca-app-pub-3634340207015593/9947032927';
  static const String prodAndroidInterstitialId = 'ca-app-pub-3634340207015593/7269627641';
  static const String prodAndroidRewardedId = 'ca-app-pub-3634340207015593/4828286818';

  static const String prodIOSBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String prodIOSInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String prodIOSRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  // Active Ad Unit IDs
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return useProductionAds ? prodAndroidBannerId : 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return useProductionAds ? prodIOSBannerId : 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return useProductionAds ? prodAndroidInterstitialId : 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return useProductionAds ? prodIOSInterstitialId : 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  static String get rewardedInterstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return useProductionAds ? prodAndroidRewardedId : 'ca-app-pub-3940256099942544/5354046379';
    } else if (Platform.isIOS) {
      return useProductionAds ? prodIOSRewardedId : 'ca-app-pub-3940256099942544/6978759866';
    }
    return '';
  }

  /// Initializes Google Mobile Ads SDK safely
  static Future<void> init() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await MobileAds.instance.initialize();
        isInitialized = true;
        loadInterstitialAd();
        loadRewardedInterstitialAd();
        debugPrint('AdService: Google Mobile Ads SDK initialized.');
      }
    } catch (e) {
      debugPrint('AdService init note: $e');
    }
  }

  /// Check if the user has unlocked the 24h remove ads reward
  static bool isBannerRemovedFor24Hours() {
    final settings = DatabaseService.getUserSettings();
    if (settings.isProMember) return true;
    if (settings.adsRemovedUntil != null) {
      return DateTime.now().isBefore(settings.adsRemovedUntil!);
    }
    return false;
  }

  /// Removes banner ads for 24 hours
  static Future<void> grant24HourAdFree() async {
    final settings = DatabaseService.getUserSettings();
    final expireAt = DateTime.now().add(const Duration(hours: 24));
    final updated = settings.copyWith(adsRemovedUntil: expireAt);
    await DatabaseService.saveUserSettings(updated);
    debugPrint('AdService: Banner ads removed for 24 hours (until $expireAt).');
  }

  // ==================== BANNER AD ====================

  /// Creates and loads a banner ad
  static BannerAd? createBannerAd({
    required Function(BannerAd ad) onAdLoaded,
    Function(LoadAdError error)? onAdFailed,
  }) {
    if (isBannerRemovedFor24Hours()) return null;
    if (bannerAdUnitId.isEmpty) return null;

    try {
      final banner = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('AdService: Banner Ad loaded.');
            onAdLoaded(ad as BannerAd);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdService: Banner failed to load: $error');
            ad.dispose();
            onAdFailed?.call(error);
          },
        ),
      );
      banner.load();
      return banner;
    } catch (e) {
      debugPrint('AdService createBannerAd error: $e');
      return null;
    }
  }

  // ==================== INTERSTITIAL AD ====================

  /// Pre-loads interstitial ad
  static void loadInterstitialAd() {
    if (interstitialAdUnitId.isEmpty || _isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('AdService: Interstitial Ad cached.');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('AdService: Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Increments session save counter and shows interstitial after every 3rd save
  static Future<void> incrementSaveAndShowInterstitial({VoidCallback? onComplete}) async {
    _sessionSaveCounter++;
    debugPrint('AdService: Session saves counter: $_sessionSaveCounter/$sessionSavesBeforeInterstitial');

    if (_sessionSaveCounter >= sessionSavesBeforeInterstitial) {
      _sessionSaveCounter = 0;
      await showInterstitialAd(onDismissed: onComplete);
    } else {
      onComplete?.call();
    }
  }

  /// Displays the cached interstitial ad safely without blocking
  static Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Interstitial failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed?.call();
      },
    );

    try {
      await _interstitialAd!.show();
    } catch (e) {
      debugPrint('AdService showInterstitial error: $e');
      onDismissed?.call();
    }
  }

  // ==================== REWARDED INTERSTITIAL AD ====================

  /// Pre-loads rewarded interstitial ad
  static void loadRewardedInterstitialAd() {
    if (rewardedInterstitialAdUnitId.isEmpty || _isRewardedLoading || _rewardedInterstitialAd != null) return;
    _isRewardedLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isRewardedLoading = false;
          debugPrint('AdService: Rewarded Interstitial Ad cached.');
        },
        onAdFailedToLoad: (error) {
          _rewardedInterstitialAd = null;
          _isRewardedLoading = false;
          debugPrint('AdService: Rewarded Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Displays Rewarded Interstitial Ad with reward callback
  static Future<void> showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdFailed,
  }) async {
    if (_rewardedInterstitialAd == null) {
      debugPrint('AdService: Rewarded ad not ready, granting fallback reward to avoid blocking user.');
      // Never block core app usage if ad fails
      onUserEarnedReward(RewardItem(1, 'fallback_reward'));
      loadRewardedInterstitialAd();
      onAdClosed?.call();
      return;
    }

    bool earnedReward = false;

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadRewardedInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadRewardedInterstitialAd();
        // Never block core app functionality
        if (!earnedReward) {
          onUserEarnedReward(RewardItem(1, 'fallback_reward'));
        }
        onAdClosed?.call();
      },
    );

    try {
      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          earnedReward = true;
          debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
    } catch (e) {
      debugPrint('AdService showRewarded error: $e');
      if (!earnedReward) {
        onUserEarnedReward(RewardItem(1, 'fallback_reward'));
      }
      onAdClosed?.call();
    }
  }
}
