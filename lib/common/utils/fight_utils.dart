import 'package:mma_flutter/fight_event/model/fight_event_model.dart';

class CustomFightUtils {
  static String winDescriptionKor(String description) {
    if (description.toLowerCase().contains('punch')) {
      return '펀치';
    } else if (description.toLowerCase().contains('kick')) {
      return '킥';
    } else if (description.toLowerCase().contains('rear naked')) {
      return '리어네이키드 초크';
    } else if (description.toLowerCase().contains('guillotine')) {
      return '길로틴 초크';
    } else if (description.toLowerCase().contains('armbar')) {
      return '암바';
    }
    return description;
  }

  static String weightClassFromWeight(double weight) {
    if (weight <= 53) {
      return '여성 스트로급';
    } else if (weight <= 57.7) {
      return '플라이급';
    } else if (weight <= 62) {
      return '벤텀급';
    } else if (weight <= 67) {
      return '페더급';
    } else if (weight <= 72) {
      return '라이트급';
    } else if (weight <= 78) {
      return '웰터급';
    } else if (weight <= 85) {
      return '미들급';
    } else if (weight <= 94) {
      return '라이트 헤비급';
    } else {
      return '헤비급';
    }
  }

  static const Map<String, String> fightWeightClassMap = {
    'Women\'s Flyweight': '여성 플라이급',
    'Women\'s Strawweight': '여성 스트로급',
    'Women\'s Bantamweight': '여성 벤텀급',
    'Women\'s Featherweight': '여성 페더급',
    'Flyweight': '플라이급',
    'Bantamweight': '벤텀급',
    'Featherweight': '페더급',
    'Lightweight': '라이트급',
    'Welterweight': '웰터급',
    'Middleweight': '미들급',
    'Light Heavyweight': '라이트 헤비급',
    'Heavyweight': '헤비급',
    'Super Heavyweight': '슈퍼 헤비급',
    'Catch Weight': '캐치 웨이트',
    'Open Weight': '오픈 웨이트',
  };

  static const Map<WinMethod, String> winMethodMap = {
    WinMethod.sub: '서브미션',
    WinMethod.koTko: 'KO/TKO',
    WinMethod.sDec: '판정(스플릿)',
    WinMethod.mDec: '판정(다수결)',
    WinMethod.uDec: '판정(만장일치)',
    WinMethod.dq: '실격',
    WinMethod.dec: '판정',
  };

  static String beltNameByPoint({required int point}) {
    switch (point) {
      case < 10000:
        return '화이트 벨트';
      case < 20000:
        return '블루 벨트';
      case < 50000:
        return '퍼플 벨트';
      case < 100000:
        return '브라운 벨트';
      default:
        return '블랙 벨트';
    }
  }

  static String renderRecord(FightRecordModel record) {
    return '${record.win}승 ${record.loss}패 ${record.draw}무';
  }

  static String extractLastName(String name) {
    if (name.contains(' ')) {
      List<String> names = name.split(' ');
      return names.sublist(1).join(' ');
    }
    return name;
  }

}
