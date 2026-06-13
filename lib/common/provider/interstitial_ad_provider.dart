import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mma_flutter/common/service/admob_service.dart';

final interstitialAdProvider =
    StateNotifierProvider<InterstitialAdNotifier, InterstitialAd?>(
      (ref) => InterstitialAdNotifier(),
    );

class InterstitialAdNotifier extends StateNotifier<InterstitialAd?> {
  InterstitialAdNotifier() : super(null);

  void load() {
    if (state == null) {
      InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            state = ad;
          },
          onAdFailedToLoad: (error) {
            state = null;
          },
        ),
      );
    }
  }

  void show({bool pop = false, VoidCallback? onComplete}) {
    final ad = state;

    if (ad == null) {
      onComplete?.call();
      if (pop) SystemNavigator.pop();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      // 정상적으로 광고가 표시된 뒤 사용자가 닫았을 때
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = null;
        onComplete?.call();
        load();
        if (pop) SystemNavigator.pop();
      },
      // 광고를 띄우는 것 자체가 실패했을 때
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        state = null;
        onComplete?.call();
        load();
        if (pop) SystemNavigator.pop();
      },
    );
    ad.show();
    state = null;
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}
