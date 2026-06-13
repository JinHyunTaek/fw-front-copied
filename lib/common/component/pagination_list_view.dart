import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/pagination_notifier.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/main.dart';

class PaginationListView<
  T extends ModelWithId,
  U extends PaginationBaseRepository<T>
>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationNotifier<T, U>, PaginationBase>
  provider;
  final Widget Function(BuildContext context, int index, T model) itemBuilder;
  final Map<String, dynamic>? params;

  // final Widget loadingWidget;

  const PaginationListView({
    super.key,
    required this.provider,
    required this.itemBuilder,
    // required this.loadingWidget,
    this.params,
  });

  @override
  ConsumerState<PaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends ModelWithId>
    extends ConsumerState<PaginationListView<T, PaginationBaseRepository<T>>> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(listener);
  }

  void listener() {
    if (!_controller.hasClients) return;
    if (_controller.offset > _controller.position.maxScrollExtent - 300) {
      _fetchMore();
    }
  }

  // 데이터가 화면을 다 채우지 못해 스크롤이 불가능한 경우(짧은 아이템 + 긴 화면)
  // listener가 호출되지 않아 더보기가 동작하지 않는다.
  // 매 프레임 이후 뷰포트가 채워졌는지 확인하고, 채워질 때까지(혹은 다음 데이터가 없을 때까지) 추가 로드한다.
  // maxScrollExtent : (콘텐츠 전체 높이) - (뷰포트(스크롤 가능한 위젯에서 지금 화면에 실제로 보이는 영역(창) 높이)
  void _fetchMoreIfViewportNotFilled() {
    if (!_controller.hasClients) return;
    if (_controller.position.maxScrollExtent <= 0) {
      _fetchMore();
    }
  }

  void _fetchMore() {
    final state = ref.read(widget.provider);
    // 이미 추가 로딩 중이거나, 더 이상 다음 데이터가 없으면 요청하지 않는다.
    if (state is PaginationFetchingMore) return;
    if (state is! Pagination) return;
    if (state.meta.empty) return;
    final updatedParams = {'page': state.meta.number + 1, ...?widget.params};
    ref
        .read(widget.provider.notifier)
        .paginateWithThrottle(fetchMore: true, params: updatedParams);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);
    if (state is PaginationLoading) {
      return CustomCircularProgressIndicator();
    }
    if (state is PaginationError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.message, textAlign: TextAlign.center),
          RetryButton(
            onRetry:
                () => ref
                    .read(widget.provider.notifier)
                    .paginateWithThrottle(forceRefetch: true),
          ),
        ],
      );
    }
    final page = state as Pagination<T>;
    // 빌드 후 뷰포트가 채워지지 않았다면(스크롤 불가) 추가 데이터를 로드한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchMoreIfViewportNotFilled();
    });
    return RefreshIndicator(
      color: context.colors.onSurface,
      onRefresh: () async {
        ref
            .read(widget.provider.notifier)
            .paginateWithThrottle(forceRefetch: true);
      },
      child: ListView.separated(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemCount: page.content.length + 1,
        itemBuilder: (_, index) {
          if (index == page.content.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child:
                    page is PaginationFetchingMore
                        ? CustomCircularProgressIndicator()
                        : SizedBox.shrink(),
              ),
            );
          }
          final pItem = page.content[index];
          return widget.itemBuilder(context, index, pItem);
        },
        separatorBuilder: (_, index) {
          return SizedBox(height: 16.h);
        },
      ),
    );
  }
}
