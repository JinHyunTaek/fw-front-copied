import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_detail_stat.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_name_versus_name.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/fighter_fight_event_detail_model.dart';
import 'package:mma_flutter/fight_event/screen/fighter_fight_event/fighter_fight_event_result_stat.dart';
import 'package:mma_flutter/main.dart';

class FighterFightEventResultStatTabView extends StatelessWidget {
  final FighterFightEventFighterModel winner;
  final FighterFightEventFighterModel loser;
  final FightResultModel result;

  const FighterFightEventResultStatTabView({
    super.key,
    required this.winner,
    required this.loser,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: SizedBox(
                height: 45.h,
                child: TabBar(
                  indicatorColor: BLUE_COLOR,
                  dividerColor: Colors.transparent,
                  labelColor: context.colors.onSurface,
                  unselectedLabelColor: GREY_COLOR,
                  tabs: const [Tab(text: '선수 프로필'), Tab(text: '경기 결과')],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: FighterFightEventNameVersusName(
                          winner: winner,
                          loser: loser,
                          versus: true,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            width: 362.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadiusGeometry.all(Radius.circular(8.r)),
                              color: context.colors.box,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(top: 31.h),
                              child: FighterFightEventDetailStat(
                                winner: winner,
                                loser: loser,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: FighterFightEventNameVersusName(
                          winner: winner,
                          loser: loser,
                          versus: true,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: FighterFightEventResultStat(
                            winner: winner,
                            loser: loser,
                            result: result,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
