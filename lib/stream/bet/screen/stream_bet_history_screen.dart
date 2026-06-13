import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/component/bet_history_cards.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_history_provider.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class StreamBetHistoryScreen extends ConsumerWidget {
  final TabController tabController;
  final int userPoint;
  final bool? isRankingScreen;

  const StreamBetHistoryScreen({
    required this.tabController,
    required this.userPoint,
    this.isRankingScreen = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = ref.watch(selectedBetHistoryEventIdProvider);
    final user = ref.watch(userProvider);

    if (eventId == null || user is! UserModel) {
      return Container(
        color: context.colors.surface,
        child: CustomCircularProgressIndicator(),
      );
    }

    final state = ref.watch(betHistoryProvider(eventId))[eventId];

    if (state is StateLoading) {
      return Container(
        color: context.colors.surface,
        child: CustomCircularProgressIndicator(),
      );
    }

    if (state is StateError) {
      return Container(
        color: context.colors.surface,
        child: RetryButton(
          onRetry:
              () =>
                  ref
                      .read(betHistoryProvider(eventId).notifier)
                      .getBetHistory(),
        ),
      );
    }

    final betHistory = state as StateData<BetResponseModel>;

    return SafeArea(
      child: RefreshIndicator(
        color: context.colors.onSurface,
        onRefresh: () async {
          ref
              .read(betHistoryProvider(eventId).notifier)
              .getBetHistory(forceRefetch: true);
        },
        child: BetHistoryCards(
          eventName: betHistory.data!.eventName,
          betResponse: betHistory.data!,
          eventId: eventId,
          userPoint: user.point,
          tabController: tabController,
        ),
      ),
    );
  }
}
