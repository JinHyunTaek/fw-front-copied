import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_detail_model.dart';
import 'package:mma_flutter/fighter/repository/fighter_repository.dart';

final fighterDetailProvider =
    FutureProvider.family.autoDispose<FighterDetailModel, int>((ref, id) async {
  return await ref.read(fighterRepositoryProvider).detail(fighterId: id);
});

final fighterYearFightEventsProvider =
    FutureProvider.family<List<FighterFightEventModel>, (int, int)>(
        (ref, params) async {
  final (fighterId, year) = params;
  return await ref
      .read(fighterRepositoryProvider)
      .getFightEventsByYear(fighterId: fighterId, year: year);
});
