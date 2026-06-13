import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/pagination_list_view.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fighter/screen/fighter_detail_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/ranking/model/rating_ranker_model.dart';
import 'package:mma_flutter/ranking/repository/fighter_rating_ranking_repository.dart';

class FighterRatingRankingScreen extends ConsumerWidget {
  const FighterRatingRankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          'FIGHTER RATING',
          style: context.text.bodyMedium?.copyWith(
            fontSize: 28.sp,
            fontFamily: 'Dalmation',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 362.w,
              child: Column(
                children: [
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: context.colors.box,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.r),
                        topLeft: Radius.circular(8.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48.w,
                          child: Center(
                            child: Text(
                              '랭킹',
                              style: context.text.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 45.w),
                        Expanded(
                          child: Text(
                            '선수',
                            style: context.text.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 80.w,
                          child: Text(
                            '호감도',
                            style: context.text.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                      ),
                      child: PaginationListView<
                        RatingRankerModel,
                        RatingRankingRepository
                      >(
                        provider: fighterRatingRankingPaginationProvider,
                        itemBuilder: (context, index, model) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 52.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.pushNamed(
                                      FighterDetailScreen.routeName,
                                      pathParameters: {
                                        'id': model.id.toString(),
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 48.w,
                                        child: Text(
                                          '#${index + 1}',
                                          style: context.text.bodySmall
                                              ?.copyWith(
                                                fontFamily: 'Dalmation',
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      _renderHeadshot(context),
                                      Expanded(
                                        child: Text(
                                          model.name,
                                          style: context.text.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80.w,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              model.avgRating.toStringAsFixed(
                                                1,
                                              ),
                                              style: context.text.bodySmall,
                                            ),
                                            SizedBox(width: 2.w),
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 14.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1.h,
                                thickness: 1,
                                color: GREY_COLOR,
                                indent: 8.w,
                                endIndent: 8.w,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderHeadshot(BuildContext context) {
    return Image.asset(
      height: 44.h,
      'asset/img/component/default-head.png',
      color: context.colors.onSurface,
    );
  }
}
