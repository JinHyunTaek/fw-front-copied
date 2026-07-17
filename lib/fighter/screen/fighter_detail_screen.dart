import 'dart:io';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';
import 'package:mma_flutter/alert/repository/alert_repository.dart';
import 'package:mma_flutter/common/component/fighter_image.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/component/card/expandable_fighter_fight_event_card.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_rating_request_model.dart';
import 'package:mma_flutter/fighter/repository/fighter_repository.dart';
import 'package:mma_flutter/fighter/utils/fighter_utils.dart';
import 'package:mma_flutter/fighter/model/fighter_detail_model.dart';
import 'package:mma_flutter/fighter/provider/fighter_provider.dart';
import 'package:mma_flutter/main.dart';

class FighterDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'fighter_detail';
  final int id;

  const FighterDetailScreen({required this.id, super.key});

  @override
  ConsumerState<FighterDetailScreen> createState() =>
      _FighterDetailScreenState();
}

class _FighterDetailScreenState extends ConsumerState<FighterDetailScreen>
    with SingleTickerProviderStateMixin {
  static const int _yearCount = 20;
  final int _currentYear = DateTime.now().year;
  late final List<int> _years;
  late final TabController _yearTabController;
  late int _selectedYear;
  IconData? _heart;
  int? _myRating;
  double? avgRating;
  late final Debouncer<int> _ratingDebounce;
  late final Debouncer<bool> _alertDebounce;

  @override
  void initState() {
    super.initState();
    _years = List.generate(
      _yearCount,
      (i) => _currentYear - (_yearCount - 1) + i,
    );
    _ratingDebounce = Debouncer(
      const Duration(milliseconds: 500),
      initialValue: 0, // dummy
      checkEquality: true,
    );
    _alertDebounce = Debouncer(
      const Duration(milliseconds: 500),
      initialValue: false,
      checkEquality: false,
    );
    _ratingDebounce.values.listen((star) {
      ref
          .read(fighterRepositoryProvider)
          .updateRating(
            request: FighterRatingRequestModel(
              fighterId: widget.id,
              rating: star,
            ),
          );
    });
    _alertDebounce.values.listen((isOn) {
      ref
          .read(alertRepositoryProvider)
          .updateSingleAlert(
            request: UpdateAlertRequest(
              targetId: widget.id,
              on: isOn,
              alertTarget: AlertTarget.fighter,
            ),
          );
    });

    _selectedYear = _currentYear;
    _yearTabController = TabController(
      length: _yearCount,
      initialIndex: _yearCount - 1,
      vsync: this,
    );
    _yearTabController.addListener(() {
      if (!_yearTabController.indexIsChanging) {
        setState(() => _selectedYear = _years[_yearTabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _yearTabController.dispose();
    _ratingDebounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(fighterDetailProvider(widget.id), (_, next) {
      next.whenData((data) {
        if (_heart == null) {
          setState(() {
            _heart =
                data.alert
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart;
          });
        }
      });
    });
    ref.listen(fighterDetailProvider(widget.id), (_, next) {
      next.whenData((data) {
        if (_myRating == null) {
          setState(() {
            _myRating = data.myRating;
          });
        }
      });
    });

    final state = ref.watch(fighterDetailProvider(widget.id));

    return state.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (_, __) => Scaffold(
            appBar: AppBar(centerTitle: true),
            body: RetryButton(
              onRetry: () => ref.invalidate(fighterDetailProvider(widget.id)),
            ),
          ),
      data:
          (data) => Scaffold(
            backgroundColor: context.colors.surface,
            appBar: AppBar(),
            body: _renderInfo(data),
          ),
    );
  }

  _renderInfo(FighterDetailModel data) {
    final nameWithNickname =
        data.nickname != null && data.nickname!.isNotEmpty
            ? FighterUtils.splitFirstAndLastName(data.name).join(
              ' \''
              '${data.nickname}'
              '\' ',
            )
            : data.name;

    return SafeArea(
      child: SizedBox.expand(
        child: SingleChildScrollView(
          physics:
              Platform.isIOS
                  ? const BouncingScrollPhysics()
                  : const ClampingScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  if (data.weight != null)
                    Text(
                      '${CustomFightUtils.weightClassFromWeight(data.weight!)} ${data.ranking == 0 ? '챔피언' : '파이터'}',
                      style: TextStyle(
                        color: context.colors.subText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(
                    width: 292.w,
                    child: Row(
                      children: [
                        if (data.ranking != null && data.ranking! >= 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            color:
                                data.ranking == 0
                                    ? Colors.yellow
                                    : context.colors.onSurface,
                            child: Text(
                              '# ${data.ranking == 0 ? 'C' : data.ranking}',
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.surface,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            data.koreanName ?? data.name,
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        _heart != null
                            ? _headerIcon(icon: _heart!)
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Text(
                    nameWithNickname,
                    style: context.text.bodySmall?.copyWith(
                      color: MID_GREY_COLOR,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  _renderRating(
                    fighterId: data.id,
                    avgRating: data.avgRating,
                    myRating: data.myRating,
                  ),
                  _imageCard(context, data.bodyUrl),
                ],
              ),
              Container(
                height: 116.h,
                width: 362.w,
                decoration: BoxDecoration(
                  color: context.colors.box,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRecord(
                      name: '승',
                      value: data.record.win,
                      color: BLUE_COLOR,
                    ),
                    _buildRecord(
                      name: '패',
                      value: data.record.loss,
                      color: RED_COLOR,
                    ),
                    _buildRecord(
                      name: '무',
                      value: data.record.draw,
                      color: GREY_COLOR,
                    ),
                  ],
                ),
              ),
              _renderDetailInfo(data),
              _footer(data),
            ],
          ),
        ),
      ),
    );
  }

  _imageCard(BuildContext context, String? bodyUrl) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: FighterImage.body(
        imageUrl: bodyUrl,
        height: 246.h,
        width: 223.w,
        silhouetteColor: context.colors.onSurface,
      ),
    );
  }

  _buildRecord({
    required String name,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: Text(name, style: TextStyle(color: color, fontSize: 18.sp)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 17.h),
          child: Container(color: color, height: 2.h, width: 65.w),
        ),
        Text(
          value.toString(),
          style: context.text.bodyMedium?.copyWith(fontSize: 24.sp),
        ),
      ],
    );
  }

  Widget _renderRating({
    required int fighterId,
    required double avgRating,
    required int myRating,
  }) {
    avgRating = (avgRating * 10).floor() / 10;
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                '전체 호감도',
                style: TextStyle(
                  color: context.colors.subText,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    '$avgRating',
                    style: context.text.bodyMedium?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                ],
              ),
            ],
          ),
          SizedBox(width: 32.w),
          Column(
            children: [
              Text(
                '나의 호감도',
                style: TextStyle(
                  color: context.colors.subText,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _myRating = star);
                      _ratingDebounce.setValue(star);
                      // optimistic update
                    },
                    child: Icon(
                      _myRating != null && _myRating! >= star
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 24.sp,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _renderDetailInfo(FighterDetailModel fighter) {
    return Padding(
      padding: EdgeInsets.only(top: 31.h, bottom: 16.h),
      child: SizedBox(
        width: 300.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _renderLabelWithValue(
                  label: '출생',
                  value:
                      fighter.birthday != null
                          ? CustomDateUtils.formatDateWithYear(fighter.birthday!)
                          : '-',
                ),
                _renderLabelWithValue(
                  label: '나이',
                  value:
                      '만 ${fighter.birthday != null ? _calculateAge(fighter.birthday!) : '-'}세',
                ),
                _renderLabelWithValue(
                  label: '국적',
                  value: fighter.nationality?.label ?? '-',
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _renderLabelWithValue(
                  label: '신장',
                  value: '${fighter.height} cm',
                ),
                _renderLabelWithValue(
                  label: '무게',
                  value: '${fighter.weight} kg',
                ),
                _renderLabelWithValue(
                  label: '리치',
                  value: '${fighter.reach} cm',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderLabelWithValue({required String label, required String value}) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: defaultTextStyle.copyWith(
                color: MID_GREY_COLOR,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 22.w),
            Text(value, style: context.text.bodyMedium),
          ],
        ),
        SizedBox(height: 15.h),
      ],
    );
  }

  int _calculateAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year - 1;
    if (birthday.month < now.month ||
        (birthday.month == now.month && birthday.day < now.day)) {
      age++;
    }
    return age;
  }

  Widget _footer(FighterDetailModel data) {
    return Container(
      color: context.colors.box,
      child: Column(
        children: [
          TabBar(
            controller: _yearTabController,
            isScrollable: true,
            indicatorColor: BLUE_COLOR,
            dividerColor: Colors.transparent,
            labelColor: context.colors.onSurface,
            unselectedLabelColor: MID_GREY_COLOR,
            tabAlignment: TabAlignment.start,
            tabs: _years.map((y) => Tab(text: '$y년')).toList(),
            labelStyle: context.text.bodyMedium,
          ),
          SizedBox(height: 4.h),
          _selectedYear == _currentYear
              ? _fightEventList(data.fighterFightEvents ?? [])
              : _yearFightEvents(),
        ],
      ),
    );
  }

  Widget _fightEventList(List<FighterFightEventModel> events) {
    return Column(
      children:
          events
              .map(
                (ffe) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: ExpandableFighterFightEventCard(ffe: ffe),
                ),
              )
              .toList(),
    );
  }

  Widget _yearFightEvents() {
    final state = ref.watch(
      fighterYearFightEventsProvider((widget.id, _selectedYear)),
    );
    return state.when(
      loading:
          () => Padding(
            padding: EdgeInsets.all(24.h),
            child: CustomCircularProgressIndicator(),
          ),
      error:
          (_, __) => RetryButton(
            onRetry:
                () => ref.invalidate(
                  fighterYearFightEventsProvider((widget.id, _selectedYear)),
                ),
          ),
      data: (events) => _fightEventList(events),
    );
  }

  _headerIcon({required IconData icon}) {
    return GestureDetector(
      child: FaIcon(icon, size: 24.0, color: GREY_COLOR),
      onTap: () {
        // heart : 채워지지 않은 하트로서, isOn은 해당 하트를 색으로 채우겠다는 의미
        final isOn = icon == FontAwesomeIcons.heart;
        if (isOn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('이제부터 해당 선수에 대한 경기 알림을 받습니다.'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        _alertDebounce.setValue(isOn);
        setState(() {
          _heart = isOn ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart;
        });
      },
    );
  }
}
