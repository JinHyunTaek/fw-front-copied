import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fight_event/component/card/fight_event_card_header.dart';
import 'package:mma_flutter/fight_event/component/card/fight_event_card_list.dart';
import 'package:mma_flutter/fight_event/component/card/fighter_fight_event_card_row.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_provider.dart';
import 'package:mma_flutter/fight_event/screen/fighter_fight_event/fighter_fight_event_detail_screen.dart';
import 'package:mma_flutter/main.dart';

class ExpandableFighterFightEventCard extends ConsumerStatefulWidget {
  final FighterFightEventModel ffe;
  final bool useAlertIcon;
  final CardDateTimeInfoModel? cardStartDateTimeInfo;
  final String? whichCard;

  const ExpandableFighterFightEventCard({
    super.key,
    required this.ffe,
    this.cardStartDateTimeInfo,
    this.useAlertIcon = false,
    this.whichCard,
  });

  @override
  ConsumerState<ExpandableFighterFightEventCard> createState() =>
      _ExpandableFighterFightEventCardState();
}

class _ExpandableFighterFightEventCardState
    extends ConsumerState<ExpandableFighterFightEventCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 362.w,
      child: Column(
        children: [
          FightEventCardHeader(
            eventId: widget.ffe.eventId,
            eventName: widget.ffe.eventName,
            isUpcoming: widget.ffe.result == null,
            useAlertIcon: widget.useAlertIcon,
            displayDate: widget.ffe.displayDate,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return FighterFightEventDetailScreen(
                                eventName: widget.ffe.eventName,
                                id: widget.ffe.id,
                                fightWeight: widget.ffe.fightWeight,
                                isTitle: widget.ffe.title,
                                cardStartDateTimeInfo:
                                    widget.cardStartDateTimeInfo,
                                whichCard: widget.whichCard,
                                result: widget.ffe.result,
                              );
                            },
                          ),
                        );
                      },
                      child: FighterFightEventCardRow(ffe: widget.ffe),
                    ),
                    if (_isExpanded) _renderAllCards(),
                  ],
                ),
              ),
              Positioned(
                bottom: -8.h,
                left: 0,
                right: 0,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: GREY_COLOR, width: 1.w),
                    color: context.colors.box,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: context.colors.onSurface,
                      size: 18.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Widget _renderAllCards() {
    final eventState = ref.watch(
      fightEventProvider(formatDateKey(widget.ffe.displayDate)),
    );
    return eventState.when(
      loading: () => CustomCircularProgressIndicator(),
      error: (_, __) => SizedBox.shrink(),
      data: (data) {
        if (data == null) return SizedBox.shrink();
        return Column(
          children: [...data.map((e) => FightEventCardList(fe: e))],
        );
      },
    );
  }
}
