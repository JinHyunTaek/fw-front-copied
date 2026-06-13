import 'dart:io' as data;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
const PRIVACY_POLICY_URL = 'https://jinhyuntaek.github.io/fightweek-privacy/';
late final String appVersion;
late final String baseUrl;
const storage = FlutterSecureStorage();

Image beltByPoint({required int point, double? width, double? height}) {
  String beltUrl = 'asset/img/icon/belt/white_belt.png';
  switch (point) {
    case < 10000:
      break;
    case < 20000:
      beltUrl = 'asset/img/icon/belt/blue_belt.png';
    case < 50000:
      beltUrl = 'asset/img/icon/belt/purple_belt.png';
    case < 100000:
      beltUrl = 'asset/img/icon/belt/brown_belt.png';
    default:
      beltUrl = 'asset/img/icon/belt/black_belt.png';
  }
  return Image.asset(beltUrl, width: width ?? 66.w, height: height ?? 66.h);
}

final easyGameDescription = '랭커, 인기 선수';
final hardGameDescription = '모든 UFC 선수';

Future<bool> get isEmulatorOrSimulator async {
  final deviceInfo = DeviceInfoPlugin();

  if (data.Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice == false ||
        androidInfo.fingerprint.contains("generic") ||
        androidInfo.model.contains("Emulator") ||
        androidInfo.brand.contains("generic");
  } else if (data.Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.isPhysicalDevice == false;
  }
  return false;
}

final String mainCard = '메인';
final String prelimCard = '언더';
final String earlyCard = '파이트 패스 언더';
