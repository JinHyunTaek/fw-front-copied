import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/provider/pagination_notifier.dart';
import 'package:mma_flutter/ranking/model/user_ranking_model.dart';
import 'package:mma_flutter/user/repository/user_repository.dart';

final userRankingProvider = FutureProvider<UserRankingModel>((ref) async {
  return await ref.read(userRepositoryProvider).getUserRanking();
});

final userRecentBetsFutureProvider = FutureProvider.family((ref, int id) {
  return ref.read(userRepositoryProvider).getUserRecentBetHistory(userId: id);
},);
