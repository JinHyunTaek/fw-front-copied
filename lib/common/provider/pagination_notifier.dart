import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';
import 'package:debounce_throttle/debounce_throttle.dart';

class PaginationInfo {
  final int fetchCount;

  // 추가로 데이터 더 가져오기
  // true - 추가로 데이터 더 가져옴
  // false - 새로고침 (현재 상태를 덮어씌움)
  final bool fetchMore;

  // 강제로 다시 로딩하기
  // true - CursorPaginationLoading()
  final bool forceRefetch;
  final Map<String, dynamic>? params;

  PaginationInfo({
    this.forceRefetch = false,
    this.fetchMore = false,
    this.fetchCount = 10,
    this.params,
  });
}

abstract class PaginationNotifier<
  T extends ModelWithId,
  U extends PaginationBaseRepository<T>
>
    extends StateNotifier<PaginationBase> {
  final U repository;
  final paginationThrottle = Throttle(
    Duration(seconds: 1),
    initialValue: PaginationInfo(),
    checkEquality: false,
  );
  final paginationDebounce = Debouncer(
    Duration(milliseconds: 500),
    initialValue: PaginationInfo(),
    checkEquality: false,
  );

  PaginationNotifier({required this.repository}) : super(PaginationLoading()) {
    paginateWithThrottle();
    paginationThrottle.values.listen((event) {
      throttledPagination(event);
    });
    paginationDebounce.values.listen((event) {
      throttledPagination(event);
    });
  }

  //  Debounce는 타이핑을 멈춘 뒤 마지막 한 번만 요청하므로 검색에 적합
  Future<void> paginateWithDebounce({
    bool forceRefetch = false,
    Map<String, dynamic>? params,
  }) async {
    paginationDebounce.setValue(
      PaginationInfo(forceRefetch: forceRefetch, params: params),
    );
  }

  // Throttle은 함수 호출 되면 바로 실행되어 버리고, 특정 기간 동안 호출되는 해당 함수 호출을 취소(페이징에 적합)
  Future<void> paginateWithThrottle({
    int fetchCount = 10,
    bool fetchMore = false,
    bool forceRefetch = false,
    Map<String, dynamic>? params,
  }) async {
    paginationThrottle.setValue(
      PaginationInfo(
        fetchCount: fetchCount,
        fetchMore: fetchMore,
        forceRefetch: forceRefetch,
        params: params,
      ),
    );
  }

  Future<void> throttledPagination(PaginationInfo info) async {
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;
    final params = info.params;
    try {
      if (state is Pagination && !forceRefetch) {
        final pState = state as Pagination;
        if (pState.meta.empty) {
          log('empty');
          // 여기까지 오는 상황 : 하단 끝까지 내림 & 더 이상 다음 데이터가 없음
          return;
        }
      }
      // 이미 데이터가 있는 상태에서 데이터를 더 가져오는 것이므로, Pagination 으로 타입 캐스팅
      if (fetchMore) {
        final pState = state as Pagination<T>;
        state = PaginationFetchingMore(
          meta: pState.meta,
          content: pState.content,
        );
      } else {
        // 새로고침(forceRefetch)하거나 아예 처음부터 불러오는 경우
        if (forceRefetch) state = PaginationLoading();
      }
      final resp = await repository.paginate(params: params);
      if (state is PaginationFetchingMore) {
        final pState = state as PaginationFetchingMore<T>;
        state = resp.copyWith(
          content: [...pState.content, ...resp.content],
          meta: resp.meta,
        );
      } else {
        state = resp;
      }
    } catch (e) {
      log('$e');
      state = PaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}
