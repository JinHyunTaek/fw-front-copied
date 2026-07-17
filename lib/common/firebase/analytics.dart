import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';

/// 앱 전역에서 사용하는 Firebase Analytics 래퍼.
///
/// 회원가입 등 핵심 전환 이벤트를 기록한다. `sign_up`은 Google Ads 앱 캠페인의
/// 전환 이벤트로 import 하여 유저 유치 최적화에 사용한다.
class Analytics {
  Analytics._();

  static final FirebaseAnalytics instance = FirebaseAnalytics.instance;

  /// 화면 이동 자동 추적용 옵저버 (screen_view 이벤트 → 가입 퍼널 분석).
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: instance);

  /// 회원가입 완료. [method]은 가입 경로(email / google / kakao / naver / apple).
  ///
  /// 분석 로깅은 best-effort: 전송이 실패해도 호출부(가입 플로우)에 예외를
  /// 전파하지 않는다. (Firebase 미초기화/오프라인 등으로 가입이 막히면 안 됨)
  static Future<void> logSignUp({required String method}) async {
    try {
      await instance.logSignUp(signUpMethod: method);
    } catch (e) {
      log('Analytics.logSignUp failed: $e', name: 'Analytics');
    }
  }
}
