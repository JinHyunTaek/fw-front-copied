import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';
import 'package:mma_flutter/alert/repository/alert_repository.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fight_event/component/card/expandable_fighter_fight_event_card.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/component/fighter_card.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/provider/user_profile_provider.dart';

class Footer extends ConsumerStatefulWidget {
  const Footer({super.key});

  @override
  ConsumerState<Footer> createState() => _FooterState();
}

class _FooterState extends ConsumerState<Footer> {
  List<FighterModel>? _fighters;
  List<FighterFightEventModel>? _events;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);

    return profileState.when(
      loading: () {
        _fighters = null;
        _events = null;
        return CustomCircularProgressIndicator();
      },
      error: (_, __) => RetryButton(onRetry: () => ref.invalidate(userProfileProvider),),
      data: (profile) {
        // _fighters ??= List.from(...) 는 _fighters가 null일 때만 오른쪽을 실행해서 할당하는 연산자임.
        // build는 여러 번 호출될 수 있는데, 매번 서버 데이터로 덮어쓰면 사용자가 dismiss한 항목이 다시 나타남.
        // 그래서 최초 1회만 서버 데이터로 초기화하고 이후엔 로컬 _fighters를 그대로 사용하는 것.
        _fighters ??= List.from(profile.alertFighters);
        _events ??= List.from(profile.alertEvents);

        return DefaultTabController(
          length: 2,
          child: SizedBox(
            width: 362.w,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 38.h, bottom: 10.h),
                  child: SizedBox(
                    height: 45.h,
                    child: TabBar(
                      indicatorColor: BLUE_COLOR,
                      dividerColor: Colors.transparent,
                      labelColor: context.colors.onSurface,
                      unselectedLabelColor: GREY_COLOR,
                      tabs: const [Tab(text: '즐겨 찾는 선수'), Tab(text: '관심 있는 이벤트')],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.separated(
                        itemCount: _fighters!.length,
                        itemBuilder: (context, index) {
                          final fighter = _fighters![index];
                          return _dismissibleWidget(
                            objectKey: ValueKey(fighter.id),
                            onDismissed: (_) {
                              setState(() => _fighters!.removeAt(index));
                              ref.read(alertRepositoryProvider).updateSingleAlert(
                                request: UpdateAlertRequest(
                                  targetId: fighter.id,
                                  on: false,
                                  alertTarget: AlertTarget.fighter,
                                ),
                              );
                            },
                            cardToRemove: SimpleFighterCard(fighter: fighter),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 11.h),
                      ),
                      ListView.separated(
                        itemCount: _events!.length,
                        itemBuilder: (context, index) {
                          final event = _events![index];
                          return _dismissibleWidget(
                            objectKey: ValueKey(event.eventId),
                            onDismissed: (_) {
                              setState(() => _events!.removeAt(index));
                              ref.read(alertRepositoryProvider).updateSingleAlert(
                                request: UpdateAlertRequest(
                                  targetId: event.eventId,
                                  on: false,
                                  alertTarget: AlertTarget.upcomingEvent,
                                ),
                              );
                            },
                            cardToRemove: ExpandableFighterFightEventCard(ffe: event),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 11.h),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dismissibleWidget({
    required ValueKey objectKey,
    required DismissDirectionCallback? onDismissed,
    required Widget cardToRemove,
  }) {
    return Dismissible(
      key: objectKey,
      background: Container(
        decoration: BoxDecoration(
          color: GREY_COLOR,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 12.w),
        child: Icon(Icons.delete_forever, color: WHITE_COLOR),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      child: cardToRemove,
    );
  }
}
