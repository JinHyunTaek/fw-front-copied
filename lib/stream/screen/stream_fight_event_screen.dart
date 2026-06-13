import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/model/selected_fight_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';
import 'package:mma_flutter/stream/provider/stream_fight_event_provider.dart';
import 'package:mma_flutter/stream/screen/stream_fight_event_list.dart';

import '../../common/model/base_state_model.dart';

/// CARDS TAB_BAR_VIEW
class StreamFightEventScreen extends ConsumerStatefulWidget {
  final TabController tabController;

  const StreamFightEventScreen({required this.tabController, super.key});

  static String get routeName => 'event_detail';

  @override
  ConsumerState<StreamFightEventScreen> createState() =>
      _StreamFightEventScreenState();
}

class _StreamFightEventScreenState
    extends ConsumerState<StreamFightEventScreen> {
  List<bool> checkBoxValues = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    log('initialize stream_event_detail_screen!');
    final state = ref.read(streamFightEventProvider);
    if (state is StateData<StreamFightEventModel>) {
      checkBoxValues = List.generate(
        state.data!.fighterFightEvents.length,
        (index) => false,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool anyBetCheckBoxSelected = checkBoxValues.any((value) => value);

    final state = ref.watch(streamFightEventProvider);

    if (state is StateLoading) {
      return CustomCircularProgressIndicator();
    }

    if (state is StateError) {
      return RetryButton(
        onRetry: () => ref.invalidate(streamFightEventProvider),
      );
    }

    final event = state as StateData<StreamFightEventModel>;

    return SafeArea(
      child: Container(
        color: context.colors.box,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  StreamFightEventList(
                    fe: event.data!,
                    checkBoxValues: checkBoxValues,
                    checkBoxOnChanged: (value, index) {
                      final selectedCount = checkBoxValues.where((v) => v).length;
                      if(value && selectedCount >= 3){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '예측 카드는 한 번에 최대 3개까지 선택하실 수 있습니다',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        checkBoxValues[index] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            if (anyBetCheckBoxSelected)
              Positioned(
                bottom: 18.h,
                height: 31.h,
                left: 137.5.w,
                right: 137.5.w,
                child: SizedBox(
                  height: 31.h,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(betCardProvider.notifier)
                          .update(
                            (_) =>
                                event.data!.fighterFightEvents
                                    .mapIndexed((index, element) {
                                      if (checkBoxValues[index] == true) {
                                        final fight = SelectedFightModel(
                                          isFiveRound:
                                              element.title || index == 0,
                                          isTitle: element.title,
                                          fightWeight: element.fightWeight,
                                          fighterFightEventId: element.id,
                                          redFighter: FighterSelection(
                                            id: element.winner.id,
                                            name:
                                                element.winner.koreanName ??
                                                element.winner.name,
                                          ),
                                          blueFighter: FighterSelection(
                                            id: element.loser.id,
                                            name:
                                                element.loser.koreanName ??
                                                element.loser.name,
                                          ),
                                        );
                                        return BetState(
                                          fight: fight,
                                          card: SelectedBetCardModel(
                                            ffeId: element.id,
                                          ),
                                        );
                                      }
                                      return null;
                                    })
                                    .whereType<BetState>()
                                    .toList(),
                          );
                      widget.tabController.animateTo(2);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: BLUE_COLOR,
                      foregroundColor: WHITE_COLOR,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      '예측하러 가기',
                      style: defaultTextStyle.copyWith(fontSize: 14.sp),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
