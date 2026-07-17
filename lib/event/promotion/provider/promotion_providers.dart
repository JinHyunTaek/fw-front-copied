import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/event/promotion/model/promotion_detail_model.dart';
import 'package:mma_flutter/event/promotion/repository/promotion_repository.dart';
import 'package:mma_flutter/home/model/home_promotion_model.dart';

/// 프로모션 상세 (id별)
final promotionDetailProvider =
    FutureProvider.family<PromotionDetailModel, int>((ref, id) async {
  return ref.read(promotionRepositoryProvider).getDetail(id: id);
});