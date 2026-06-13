import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/fighter_fight_event_detail_model.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_alert_provider.dart';
import 'package:mma_flutter/fight_event/repository/fight_event_repository.dart';

final fightDaysProvider = FutureProvider.family<List<int>, (int, int)>((
  ref,
  pair,
) async {
  return await ref
      .read(fightEventRepositoryProvider)
      .getDays(year: pair.$1, month: pair.$2);
});

final fightEventProvider =
    FutureProvider.family<List<FightEventModel>?, String>((ref, dateKey) async {
      final resp = await ref
          .read(fightEventRepositoryProvider)
          .getSchedule(date: dateKey);
      if (resp != null) {
        for (final event in resp) {
          if (event.upcoming) {
            ref.read(eventAlertStatusProvider(event.id).notifier).state =
                event.alert;
          }
        }
      }
      return resp;
    });

final fighterFightEventDetailFutureProvider =
    FutureProvider.family<FighterFightEventDetailModel, int>((
      ref,
      ffeId,
    ) async {
      return await ref
          .read(fightEventRepositoryProvider)
          .getFighterFightEventDetail(ffeId: ffeId.toString());
    });
