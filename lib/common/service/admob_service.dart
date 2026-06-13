import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mma_flutter/common/const/data.dart';

class AdMobService {
  static String get bannerAdUnitId {
    if (!kReleaseMode) {
      // Debug / Profile → 테스트 광고
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // Release → 실제 광고
    if (Platform.isAndroid) {
      return 'ca-app-pub-5956787381787938/3936615583';
    } else {
      return 'ca-app-pub-5956787381787938/8033197019';
    }
  }

  static String get rewardAdUnitId {
    if (!kReleaseMode) {
      // Debug / Profile → 테스트 광고
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }
    // Release → 실제 광고
    if (Platform.isAndroid) {
      return 'ca-app-pub-5956787381787938/3967586936';
    } else {
      return 'ca-app-pub-5956787381787938/7269714997';
    }
  }

  static String get interstitialAdUnitId {
    if (!kReleaseMode) {
      // Debug / Profile → 테스트 광고
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    }
    // Release → 실제 광고
    if (Platform.isAndroid) {
      return 'ca-app-pub-5956787381787938/1479425202';
    } else {
      return 'ca-app-pub-5956787381787938/6911687034';
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('failed to load, error = $error');
    },
    onAdOpened: (ad) => debugPrint('ad opended'),
    onAdClosed: (ad) => debugPrint('ad closed'),
  );
}
