import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fighter/utils/fighter_utils.dart';
import 'package:mma_flutter/fighter/screen/fighter_detail_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/ranking/component/hexagon_container.dart';
import 'package:mma_flutter/ranking/model/rankers_model.dart';
import 'package:mma_flutter/ranking/repository/fighter_ranking_repository.dart';

class FighterRankingScreen extends ConsumerStatefulWidget {
  const FighterRankingScreen({super.key});

  @override
  ConsumerState<FighterRankingScreen> createState() =>
      _FighterRankingScreenState();
}

class _FighterRankingScreenState extends ConsumerState<FighterRankingScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: RankingCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(tabListener);
  }

  void tabListener() {
    setState(() {
      index = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(tabListener);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = ref.watch(rankersFutureProvider(RankingCategory.values[index]));
    return res.when(
      data: (data) {
        return _frame(
          body: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                indicatorColor: BLUE_COLOR,
                dividerColor: Colors.transparent,
                tabs:
                    RankingCategory.values
                        .mapIndexed(
                          (idx, e) => Text(
                            e.description,
                            style: context.text.bodyMedium?.copyWith(
                              color:
                                  _tabController.index == idx
                                      ? context.colors.onSurface
                                      : GREY_COLOR,
                            ),
                          ),
                        )
                        .toList(),
                onTap: (value) {
                  setState(() {
                    index = value;
                  });
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children:
                      RankingCategory.values
                          .map((e) => _RankingTab(rankers: data))
                          .toList(),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        log('$error');
        log('$stackTrace');
        return _frame(
          body: RetryButton(
            onRetry: () => ref.invalidate(rankersFutureProvider),
          ),
        );
      },
      loading: () => _frame(body: CustomCircularProgressIndicator()),
    );
  }

  Widget _frame({required Widget body}) {
    return Scaffold(
      body: SafeArea(child: body),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          centerTitle: true,
          title: Text(
            'FIGHTER RANKING',
            style: context.text.bodyMedium?.copyWith(
              fontSize: 28.sp,
              fontFamily: 'Dalmation',
            ),
          ),
        ),
      ),
      backgroundColor: context.colors.surface,
    );
  }
}

class _RankingTab extends StatelessWidget {
  final RankersModel rankers;

  const _RankingTab({required this.rankers});

  @override
  Widget build(BuildContext context) {
    final champ = rankers.rankers[0];
    final champName = FighterUtils.splitFirstAndLastName(
      champ.koreanName ?? champ.name,
    );
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: SizedBox(
            height: 77.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        FighterDetailScreen.routeName,
                        pathParameters: {'id': champ.id.toString()},
                      );
                    },
                    child: HexagonContainer(
                      borderWidth: 1.w,
                      borderColor: BLUE_COLOR,
                      width: 335.w,
                      height: 57.h,
                      color: context.colors.box,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: Text(
                              champ.ranking == 0 ? ' C' : '#1',
                              style: context.text.bodyMedium?.copyWith(
                                fontFamily: 'Dalmation',
                                fontSize: 36.sp,
                                color:
                                    champ.ranking == 0
                                        ? Colors.yellow
                                        : context.colors.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 90.w),
                            child: Text(
                              '${champName[0]}\n${champName[1]}',
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 60.w,
                  top: -10.h,
                  child: Image.asset(
                    'asset/img/component/default-head.png',
                    height: 77.h,
                    width: 123.w,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        _renderContenders(context, rankers: rankers.rankers),
      ],
    );
  }

  Widget _renderContenders(
    BuildContext context, {
    required List<RankerModel> rankers,
  }) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 14.h),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children:
              rankers
                  .whereIndexed((index, element) => index > 0)
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          FighterDetailScreen.routeName,
                          pathParameters: {'id': e.id.toString()},
                        );
                      },
                      child: SizedBox(
                        height: 48.h,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            HexagonContainer(
                              width: 335.w,
                              height: 26.h,
                              color: context.colors.box,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 14.w,
                                    top: 2.h,
                                    child: Text(
                                      '#${e.ranking}',
                                      style: context.text.bodyMedium?.copyWith(
                                        fontFamily: 'Dalmation',
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 130.w,
                                    top: 4.h,
                                    child: Text(
                                      e.koreanName ?? e.name,
                                      style: context.text.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 40,
                              top: -16.h,
                              child: Image.asset(
                                'asset/img/component/default-head.png',
                                height: 43.h,
                                width: 68.w,
                                color: context.colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
