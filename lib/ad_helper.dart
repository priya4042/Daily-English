import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob IDs. DEBUG uses Google's TEST units (safe). RELEASE uses the real
/// units. TODO: after creating the app in AdMob, replace the REAL ids below.
class AdHelper {
  static const String _realBanner = 'ca-app-pub-3940256099942544/6300978111';       // TODO replace
  static const String _realInterstitial = 'ca-app-pub-3940256099942544/1033173712'; // TODO replace

  static String get bannerAdUnitId =>
      kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : _realBanner;
  static String get interstitialAdUnitId =>
      kDebugMode ? 'ca-app-pub-3940256099942544/1033173712' : _realInterstitial;
}

/// Loads and shows interstitials, throttled to once every [showEvery] actions.
class InterstitialManager {
  InterstitialAd? _ad;
  bool _loading = false;
  int _count = 0;
  final int showEvery;
  InterstitialManager({this.showEvery = 4});

  void load() {
    if (_loading || _ad != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad; _loading = false;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) { ad.dispose(); _ad = null; load(); },
            onAdFailedToShowFullScreenContent: (ad, e) { ad.dispose(); _ad = null; load(); },
          );
        },
        onAdFailedToLoad: (e) { _ad = null; _loading = false; },
      ),
    );
  }

  void maybeShow() {
    _count++;
    if (_count % showEvery != 0) return;
    if (_ad != null) { _ad!.show(); } else { load(); }
  }

  void dispose() { _ad?.dispose(); _ad = null; }
}
