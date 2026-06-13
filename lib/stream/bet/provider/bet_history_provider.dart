import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';
import 'package:mma_flutter/stream/bet/repository/bet_repository.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

final betHistoryProvider = StateNotifierProvider.family<
  BetHistoryStateNotifier,
  Map<int, StateBase<BetResponseModel>>,
  int
>((ref, eventId) {
  final repository = ref.read(betRepositoryProvider);
  return BetHistoryStateNotifier(
    betRepository: repository,
    eventId: eventId,
    ref: ref,
  );
});

final selectedBetHistoryEventIdProvider = StateProvider<int?>((ref) => null);
final currentEventIdProvider = StateProvider<int?>((ref) => null);

final betCreateFutureProvider = FutureProvider.autoDispose.family<
  String?,
  BetRequestModel
>((ref, request) async {
  try {
    log(jsonEncode(request.toJson()));
    final point = await ref.read(betRepositoryProvider).bet(request: request);
    ref.read(userProvider.notifier).updatePoint(point);
    ref
        .read(betHistoryProvider(request.eventId).notifier)
        .getBetHistory(forceRefetch: true);
  } on DioException catch (e) {
    log('${e.response?.statusCode}');
    final errorMsg =
        e.response?.data['errorCode'] != null
            ? BetErrorMessage.fromCode(e.response!.data['errorCode'])?.message
            : null;
    return errorMsg ?? '알 수 없는 오류 발생';
  }
  return null;
});

class BetHistoryStateNotifier
    extends StateNotifier<Map<int, StateBase<BetResponseModel>>> {
  final BetRepository betRepository;
  final int eventId;
  final Ref ref;

  BetHistoryStateNotifier({
    required this.betRepository,
    required this.eventId,
    required this.ref,
  }) : super({eventId: StateLoading<BetResponseModel>()}) {
    log('bet history state notifier 생성됨');
    getBetHistory();
  }

  Future<String?> deleteBet({
    required int betId,
    required int eventId,
    required int seedPoint,
    required int userPoint,
  }) async {
    final prevEventState = state[eventId] as StateData<BetResponseModel>;
    try {
      state = {...state, eventId: StateLoading()};
      final resp = await betRepository.deleteBet(betId: betId);
      state = {...state, eventId: StateData(data: resp.betResponse)};
      ref.read(userProvider.notifier).updatePoint(resp.userPoint);
      return null;
    } on DioException catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      final errorMsg =
          e.response?.data['errorCode'] != null
              ? BetErrorMessage.fromCode(e.response!.data['errorCode'])?.message
              : null;
      state = {...state, eventId: prevEventState};
      log('errorMsg = $errorMsg');
      return errorMsg ?? '알 수 없는 오류 발생';
    }
  }

  Future<void> getBetHistory({bool forceRefetch = false}) async {
    try {
      if (!forceRefetch && state[eventId] is StateData) {
        return;
      }
      state = {...state, eventId: StateLoading<BetResponseModel>()};
      final resp = await betRepository.getBetHistory(eventId: eventId);
      state = {...state, eventId: StateData(data: resp)};
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      state = {
        ...state,
        eventId: StateError(message: 'error while requesting bet history'),
      };
    }
  }
}

enum BetErrorMessage {
  BET_NOT_AVAILABLE_DATE_403('예측 및 예측 취소는 경기가 있는 주말에는 이용하실 수 없습니다'),
  LOW_USER_POINT_400('보유하고 있는 포인트가 부족합니다'),
  BET_LIMIT_EXCEED_403('예측은 경기당 최대 3회 가능합니다'),
  NO_SUCH_EVENT_FOUND_400('유효하지 않은 경기입니다'),
  FIGHT_CANCELED_400('취소된 카드가 포함되어 있습니다. 재접속 후 다시 시도해주세요'),
  RESOURCE_NOT_FOUND('유효하지 않은 요청입니다. 재접속 후 시도해주세요'),
  BET_CANCEL_LIMIT_EXCEED_403('예측 취소는 경기당 최대 3회 가능합니다.');

  final String message;

  const BetErrorMessage(this.message);

  static BetErrorMessage? fromCode(String code) {
    try {
      return BetErrorMessage.values.firstWhere((e) => e.name == code);
    } catch (_) {
      return null;
    }
  }
}
