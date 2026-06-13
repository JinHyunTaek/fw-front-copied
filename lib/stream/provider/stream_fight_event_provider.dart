import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_history_provider.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';
import 'package:mma_flutter/stream/repository/stream_fight_event_repository.dart';

final streamFightEventProvider = StateNotifierProvider<
  StreamStateNotifier,
  StateBase<StreamFightEventModel>
>((ref) {
  final repository = ref.read(streamFightEventRepositoryProvider);
  return StreamStateNotifier(ref: ref, streamFightEventRepository: repository);
});

class StreamStateNotifier
    extends StateNotifier<StateBase<StreamFightEventModel>> {
  final StreamFightEventRepository streamFightEventRepository;
  final Ref ref;

  StreamStateNotifier({
    required this.ref,
    required this.streamFightEventRepository,
  }) : super(StateLoading()) {
    log('StreamStateNotifier 생성됨');
    getCurrentFightEventInfo();
  }

  Future<void> getCurrentFightEventInfo() async {
    try {
      final resp = await streamFightEventRepository.getFightEvent();
      ref.read(currentEventIdProvider.notifier).update((state) => resp.id);
      state = StateData(data: resp);
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      state = StateError(
        message: 'error while getting current fight event info',
      );
    }
  }

  void update(StreamFightEventModel model) {
    state = StateData(data: model);
  }

}
