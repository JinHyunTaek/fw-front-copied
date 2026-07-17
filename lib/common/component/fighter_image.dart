import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 선수 이미지 렌더링 공용 위젯.
///
/// - [imageUrl] 이 null/빈문자열이거나, 네트워크 로딩·에러 시 실루엣(에셋)으로 폴백한다.
/// - 실루엣에는 [silhouetteColor] 틴트를 적용하지만, 실제 이미지에는 틴트를 적용하지 않는다.
///   (선수 10%만 이미지가 존재하고 나머지는 url이 null로 내려온다.)
class FighterImage extends StatelessWidget {
  static const String headAsset = 'asset/img/component/default-head.png';
  static const String bodyAsset = 'asset/img/component/default-body.png';

  final String? imageUrl;
  final String silhouetteAsset;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? silhouetteColor;

  const FighterImage({
    super.key,
    required this.imageUrl,
    required this.silhouetteAsset,
    this.width,
    this.height,
    this.fit,
    this.silhouetteColor,
  });

  /// 얼굴 썸네일(headshotUrl)용.
  const FighterImage.head({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.silhouetteColor,
  }) : silhouetteAsset = headAsset;

  /// 전신(bodyUrl)용.
  const FighterImage.body({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.silhouetteColor,
  }) : silhouetteAsset = bodyAsset;

  Widget _silhouette() => Image.asset(
        silhouetteAsset,
        width: width,
        height: height,
        fit: fit,
        color: silhouetteColor,
      );

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _silhouette();
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _silhouette(),
      errorWidget: (_, __, ___) => _silhouette(),
    );
  }
}
