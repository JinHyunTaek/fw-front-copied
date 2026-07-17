import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/fighter_image.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_detail_stat.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_name_versus_name.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_result_stat_tab_view.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_provider.dart';
import 'package:mma_flutter/main.dart';

class FighterFightEventDetailScreen extends ConsumerWidget {
  static String get routeName => 'fighter_fight_event_detail_screen';

  final String eventName;
  final CardDateTimeInfoModel? cardStartDateTimeInfo;
  final String fightWeight;
  final bool isTitle;
  final String? whichCard;
  final int id;
  final FightResultModel? result;

  const FighterFightEventDetailScreen({
    required this.eventName,
    required this.id,
    required this.cardStartDateTimeInfo,
    required this.fightWeight,
    required this.isTitle,
    required this.whichCard,
    this.result,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(fighterFightEventDetailFutureProvider(id));
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(),
      body: data.when(
        error:
            (error, stackTrace) => RetryButton(
              onRetry:
                  () => ref.invalidate(fighterFightEventDetailFutureProvider),
            ),
        loading: () => CustomCircularProgressIndicator(),
        data: (data) {
          return SafeArea(
            child: Column(
              children: [
                Text(
                  eventName,
                  style: context.text.bodyMedium?.copyWith(fontSize: 24.sp),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${CustomFightUtils.fightWeightClassMap[fightWeight] ?? ''} ${isTitle ? '타이틀전' : '매치'}',
                        style: TextStyle(
                          color: MID_GREY_COLOR,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (whichCard != null)
                        Text(
                          ' / $whichCard 카드',
                          style: TextStyle(
                            color: MID_GREY_COLOR,
                            fontSize: 13.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                if (cardStartDateTimeInfo != null)
                  Text(
                    '${CustomDateUtils.formatDateWithYear(cardStartDateTimeInfo!.date)} ${CustomDateUtils.formatDurationToHHMM(cardStartDateTimeInfo!.time)} KST',
                    style: TextStyle(fontSize: 12.sp, color: MID_GREY_COLOR),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerRight,
                          widthFactor: 0.95.w,
                          child: _renderImageWithOpacity(
                            context,
                            isEnded: result != null,
                            isWinner: true,
                            bodyUrl: data.winner.bodyUrl,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Transform(
                            alignment: Alignment.center,
                            transform:
                                Matrix4.identity()
                                  ..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
                            child: _renderImageWithOpacity(
                              context,
                              isEnded: result != null,
                              isWinner: false,
                              bodyUrl: data.loser.bodyUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (result == null)
                  Expanded(
                    child: SizedBox(
                      width: 362.w,
                      child: Column(
                        children: [
                          FighterFightEventNameVersusName(
                            winner: data.winner,
                            loser: data.loser,
                            versus: true,
                          ),
                          SizedBox(height: 8.h),
                          Expanded(
                            child: SingleChildScrollView(
                              physics:
                                  Platform.isIOS
                                      ? const BouncingScrollPhysics()
                                      : const ClampingScrollPhysics(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.colors.box,
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(8.r),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 31.h),
                                  child: FighterFightEventDetailStat(
                                    winner: data.winner,
                                    loser: data.loser,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (result != null)
                  FighterFightEventResultStatTabView(
                    winner: data.winner,
                    loser: data.loser,
                    result: result!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _renderImageWithOpacity(
    BuildContext context, {
    required bool isEnded,
    required bool isWinner,
    required String? bodyUrl,
  }) {
    return Stack(
      children: [
        Container(
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, BLACK_COLOR.withValues(alpha: 0.6)],
            ),
          ),
          child:
              !isWinner && isEnded
                  ? ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: _renderBodyImage(context, bodyUrl),
                  )
                  : _renderBodyImage(context, bodyUrl),
        ),
        if (isWinner && isEnded && !result!.nc && !result!.draw)
          Positioned(
            left: 70.w,
            bottom: 20.h,
            child: Text(
              'WIN',
              style: defaultTextStyle.copyWith(
                fontSize: 65.sp,
                fontFamily: 'Dalmation',
                fontWeight: FontWeight.w300,
                color: RED_COLOR,
              ),
            ),
          ),
      ],
    );
  }

  Widget _renderBodyImage(BuildContext context, String? bodyUrl) {
    return FighterImage.body(
      imageUrl: bodyUrl,
      height: 301.h,
      width: 226.w,
      fit: BoxFit.contain,
      silhouetteColor: context.colors.onSurface,
    );
  }
}
