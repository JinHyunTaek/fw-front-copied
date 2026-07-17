import 'package:json_annotation/json_annotation.dart';

/// 기프티콘 카테고리. 백엔드 GifticonCategory enum과 1:1 매핑된다.
/// 각 카테고리는 상세 화면 경품 리스트에 노출할 이모지/라벨을 가진다.
enum GifticonCategory {
  @JsonValue('COFFEE')
  coffee('☕', '커피'),
  @JsonValue('CHICKEN')
  chicken('🍗', '치킨'),
  @JsonValue('DELIVERY')
  delivery('🛵', '배달'),
  @JsonValue('CONVENIENCE')
  convenience('🎫', '편의점'),
  @JsonValue('DESSERT')
  dessert('🧁', '디저트');

  final String emoji;
  final String label;

  const GifticonCategory(this.emoji, this.label);
}
