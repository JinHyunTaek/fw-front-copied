import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmTokenFutureProvider = FutureProvider<String?>((ref) async {
  final token = await ref.read(fcmTokenProvider).getToken();
  return token;
});

final fcmTokenProvider = Provider<FcmTokenProvider>((ref) {
  return FirebaseFcmTokenProvider();
});

abstract class FcmTokenProvider {
  Future<String?> getToken();
}

class FirebaseFcmTokenProvider implements FcmTokenProvider {
  @override
  Future<String?> getToken() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        return 'mock-fcm-token-emulator';
      }
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return 'mock-fcm-token-emulator';
      }
    }
    try {
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        log('apns token: $apnsToken');
        if (apnsToken == null) return null;
      }
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      return null;
    }
  }
}
