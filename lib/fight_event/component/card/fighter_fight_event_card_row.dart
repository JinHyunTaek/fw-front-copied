import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/enum/country.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fighter_fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/fighter/screen/fighter_detail_screen.dart';
import 'package:mma_flutter/fighter/utils/fighter_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';

class FighterFightEventCardRow extends ConsumerWidget {
  final IFighterFightEvent ffe;
  final Widget? betRateBar;

  const FighterFightEventCardRow({
    super.key,
    required this.ffe,
    this.betRateBar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final winnerName = FighterUtils.splitFirstAndLastName(ffe.winner.koreanName ?? ffe.winner.name);
    final loserName = FighterUtils.splitFirstAndLastName(ffe.loser.koreanName ?? ffe.loser.name);

    return Container(
      width: 362.w,
      constraints:  BoxConstraints(
        minHeight: betRateBar != null
            ? 110.h
            : ffe.result != null
            ? 105.h
            : 100.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: BoxBorder.all(color: _cardBorderColor(ffe: ffe), width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              // 상단: 랭킹 + 체급/타이틀
              SizedBox(
                height: 22.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ffe.winner.ranking != null
                        ? Padding(
                          padding: EdgeInsets.only(left: 8.w, top: 4.h),
                          child: SizedBox(
                            width: 24.w,
                            child: Text(
                              '#${ffe.winner.ranking == 0 ? 'C' : ffe.winner.ranking}',
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 12.sp,
                                color: ffe.winner.ranking == 0 ? Colors.yellow : null,
                              ),
                            ),
                          ),
                        )
                        : SizedBox(width: 24.w),
                    Center(
                      child: Text(
                        '${CustomFightUtils.fightWeightClassMap[ffe.fightWeight] ?? ffe.fightWeight} ${ffe.title ? '타이틀전' : '매치'}',
                        style: context.text.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                          color: MID_GREY_COLOR,
                        ),
                      ),
                    ),
                    ffe.loser.ranking != null
                        ? Padding(
                          padding: EdgeInsets.only(top: 4.h, right: 8.w),
                          child: Text(
                            '#${ffe.loser.ranking == 0 ? 'C' : ffe.loser.ranking}',
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 12.sp,
                              color: ffe.loser.ranking == 0 ? Colors.yellow : null
                            ),
                          ),
                        )
                        : SizedBox(width: 24.w),
                  ],
                ),
              ),
              // 중단: 선수 이미지 + 이름 + VS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _imageCard(context, ffe.winner, ref, true),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${winnerName[0]}\n${winnerName[1]}',
                                style: context.text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        if (ffe.result != null && !ffe.result!.nc)
                          _renderWinMethodFromWinner(context),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        if (ffe is FighterFightEventModel && (ffe as FighterFightEventModel).fotN)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.yellow, size: 8.sp),
                              SizedBox(width: 2.w),
                              Text(
                                'FOTN',
                                style: context.text.bodyMedium?.copyWith(
                                  color: Colors.yellow,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (ffe is FighterFightEventModel && (ffe as FighterFightEventModel).potN)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.yellow, size: 8.sp),
                              SizedBox(width: 2.w),
                              Text(
                                'POTN',
                                style: context.text.bodyMedium?.copyWith(
                                  color: Colors.yellow,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        Text(
                          'VS',
                          style: context.text.bodyMedium?.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                        if (ffe.result != null &&
                            (ffe.result!.nc || ffe.result!.draw))
                          Text(
                            ffe.result!.draw ? '무승부' : '무효',
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.subText,
                              fontSize: 8.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${loserName[0]}\n${loserName[1]}',
                                style: context.text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _imageCard(context, ffe.loser, ref, false),
                ],
              ),
            ],
          ),
          // 하단: 국기 + 국가 + 전적
          Container(
            width: 348.w,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: GREY_COLOR, width: 1.w)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _flagRecord(context, ffe.winner, isLeft: true),
                _flagRecord(context, ffe.loser, isLeft: false),
              ],
            ),
          ),
          if (betRateBar != null) betRateBar!,
        ],
      ),
    );
  }

  Widget _flagRecord(
    BuildContext context,
    FighterModel fighter, {
    required bool isLeft,
  }) {
    final Country? country = fighter.nationality;
    final record =
        '${fighter.record.win}-${fighter.record.loss}-${fighter.record.draw}';

    if (isLeft) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (country != null)
            Row(
              children: [
                Text(country.flag, style: TextStyle(fontSize: 12.sp)),
                SizedBox(width: 2.w),
                Text(
                  '${country.label}·',
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: MID_GREY_COLOR,
                  ),
                ),
                SizedBox(width: 2.w,),
              ],
            ),
          Text(
            record,
            style: context.text.bodyMedium?.copyWith(
              fontSize: 11.sp,
              color: MID_GREY_COLOR,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            record,
            style: context.text.bodyMedium?.copyWith(
              fontSize: 11.sp,
              color: MID_GREY_COLOR,
            ),
          ),
          if (country != null)
            Row(
              children: [
                SizedBox(width: 2.w,),
                Text(
                  '·${country.label}',
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: MID_GREY_COLOR,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(country.flag, style: TextStyle(fontSize: 10.sp)),
              ],
            ),
        ],
      );
    }
  }

  Widget _imageCard(
    BuildContext context,
    FighterModel fighter,
    WidgetRef ref,
    bool left,
  ) {
    return _TappableFighterImage(
      fighter: fighter,
      onTap: () {
        context.pushNamed(
          FighterDetailScreen.routeName,
          pathParameters: {'id': fighter.id.toString()},
        );
      },
    );
  }

  Widget _renderWinMethodFromWinner(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check, size: 14, color: Colors.green),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            isDec(ffe.result!.winMethod!) ? '판정' :
            CustomFightUtils.winMethodMap[ffe.result!.winMethod] ?? '',
            style: context.text.bodyMedium?.copyWith(fontSize: 10.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool isDec(WinMethod winMethod){
    return winMethod == WinMethod.uDec || winMethod == WinMethod.mDec || winMethod == WinMethod.sDec;
  }

  Color _cardBorderColor({required IFighterFightEvent ffe}) {
    if (ffe is StreamFighterFightEventModel) {
      return ffe.status == StreamFighterFightEventStatus.now
          ? BLUE_COLOR
          : GREY_COLOR;
    }
    return GREY_COLOR;
  }
}

class _TappableFighterImage extends StatefulWidget {
  final FighterModel fighter;
  final VoidCallback onTap;

  const _TappableFighterImage({required this.fighter, required this.onTap});

  @override
  State<_TappableFighterImage> createState() => _TappableFighterImageState();
}

class _TappableFighterImageState extends State<_TappableFighterImage> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          key: ValueKey(widget.fighter.id),
          width: 86.w,
          height: 57.h,
          child: Image.asset('asset/img/component/default-head.png',color: context.colors.onSurface,),
        ),
      ),
    );
  }

}
