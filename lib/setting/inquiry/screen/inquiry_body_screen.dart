import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_response_model.dart';
import 'package:mma_flutter/setting/inquiry/provider/inquiry_provider.dart';

class InquiryBodyScreen extends ConsumerWidget {
  final InquiryResponseModel model;

  const InquiryBodyScreen({required this.model, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = ref.watch(inquiryBodyFutureProvider(model.id));

    return body.when(
      data: (data) {
        return _frame(
          context,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${model.category.korean}] ${CustomDateUtils.formatDateWithYear(model.createdDate)}',
                  style: context.text.bodyMedium,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Container(height: 1.h, color: GREY_COLOR),
                ),
                Text(
                  data.content,
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusGeometry.circular(8.r),
                      color: GREY_COLOR,
                    ),
                  ),
                ),
                if (data.answer != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[답변일] ${CustomDateUtils.formatDateWithYear(model.answeredDate!)}',
                        style: context.text.bodyMedium,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Container(height: 1.h, color: GREY_COLOR),
                      ),
                    ],
                  ),
                Text(
                  data.answer ?? '고객센터의 답변을 기다리는 중입니다.',
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return _frame(
          context,
          body: RetryButton(
            onRetry: () => ref.invalidate(inquiryBodyFutureProvider),
          ),
        );
      },
      loading: () => CustomCircularProgressIndicator(),
    );
  }

  Widget _frame(BuildContext context, {required Widget body}) {
    return Scaffold(
      body: SafeArea(child: body),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '1:1 문의 상세',
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: context.colors.surface,
    );
  }
}
