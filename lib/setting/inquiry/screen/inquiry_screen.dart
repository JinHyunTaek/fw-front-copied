import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/pagination_list_view.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_response_model.dart';
import 'package:mma_flutter/setting/inquiry/provider/inquiry_provider.dart';
import 'package:mma_flutter/setting/inquiry/screen/inquiry_body_screen.dart';
import 'package:mma_flutter/setting/inquiry/screen/inquiry_request_screen.dart';

class InquiryScreen extends StatelessWidget {
  static String get routeName => 'inquiry';

  const InquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '1:1 문의',
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: context.colors.surface,
      body: DefaultTabController(
        length: 2,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                SizedBox(
                  height: 45.h,
                  child: TabBar(
                    indicatorColor: BLUE_COLOR,
                    dividerColor: Colors.transparent,
                    labelColor: context.colors.onSurface,
                    unselectedLabelColor: GREY_COLOR,
                    tabs: const [Tab(text: '문의하기'), Tab(text: '문의내역')],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      InquiryRequestScreen(),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: _firstRow(context),
                          ),
                          Expanded(
                            child: PaginationListView(
                              provider: inquiryPaginationProvider,
                              itemBuilder: (context, index, model) {
                                return _inquiryRow(context, model: model);
                              },
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
        ),
      ),
    );
  }

  Widget _firstRow(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
        color: GREY_COLOR
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '문의일',
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '분류',
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '답변일',
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '상태',
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inquiryRow(
    BuildContext context, {
    required InquiryResponseModel model,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 55.h,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return InquiryBodyScreen(model: model);
                  },
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    CustomDateUtils.formatDateWithYear(model.createdDate),
                    style: TextStyle(color: MID_GREY_COLOR, fontSize: 13.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '[${model.category.korean}]',
                    style: TextStyle(color: BLUE_COLOR, fontSize: 13.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    model.answeredDate != null
                        ? CustomDateUtils.formatDateWithYear(model.answeredDate!)
                        : '-',
                    style: context.text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    model.answeredDate == null ? '접수중' : '답변 완료',
                    style: TextStyle(
                      color:
                          model.answeredDate == null
                              ? MID_GREY_COLOR
                              : BLUE_COLOR,
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(color: MID_GREY_COLOR, height: 1.h),
      ],
    );
  }
}
