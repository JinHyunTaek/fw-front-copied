import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/inquiry/faq/model/faq_answers_response_model.dart';
import 'package:mma_flutter/setting/inquiry/faq/model/faq_response_model.dart';
import 'package:mma_flutter/setting/inquiry/faq/provider/faq_provider.dart';
import 'package:mma_flutter/setting/inquiry/screen/inquiry_screen.dart';

class FaqScreen extends ConsumerStatefulWidget {
  static String get routeName => 'faq_screen';

  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen>
    with TickerProviderStateMixin {
  FAQCategory currentCategory = FAQCategory.main;
  List<FaqResponseModel>? faqs;
  List<int> selectedQuestionIndexes = [];

  @override
  Widget build(BuildContext context) {
    final faqs = ref.watch(faqsFutureProvider);
    final faqAnswerAsync = ref.watch(
      faqsFromCategoryFutureProvider(currentCategory),
    );

    return faqs.when(
      data: (data) {
        log('$data');
        return _frame(
          body: Column(
            children: [
              _renderFaqCategories(),
              SizedBox(height: 16.h),
              Container(height: 1.h, color: LIGHT_GREY_COLOR),
              Expanded(
                child: _renderFaqQuestion(
                  faqs:
                      data
                          .where((e) => e.faqCategory == currentCategory)
                          .toList(),
                  model: faqAnswerAsync,
                ),
              ),
              Column(
                children: [
                  Text(
                    '아직 해결이 되지 않으셨나요?',
                    style: context.text.bodyMedium?.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(336.w, 34.h),
                      backgroundColor: BLUE_COLOR,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InquiryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '고객센터로 문의하기',
                      style: defaultTextStyle.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        log('$error');
        return RetryButton(onRetry: () => ref.invalidate(faqsFutureProvider));
      },
      loading:
          () => _frame(
            body: Column(
              children: [
                Text('카테고리', style: context.text.bodyMedium),
                _renderFaqCategories(),
                CustomCircularProgressIndicator(),
              ],
            ),
          ),
    );
  }

  Widget _frame({required Widget body}) {
    return Scaffold(
      body: SafeArea(child: body),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'FAQ',
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: context.colors.surface,
    );
  }

  ListView _renderFaqQuestion({
    required List<FaqResponseModel> faqs,
    required AsyncValue<FAQAnswersResponseModel> model,
  }) {
    return ListView.builder(
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                color:
                    selectedQuestionIndexes.contains(index)
                        ? GREY_COLOR
                        : context.colors.surface,
                border: Border.symmetric(
                  horizontal: BorderSide(color: GREY_COLOR, width: 1.w),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (!selectedQuestionIndexes.contains(index)) {
                      selectedQuestionIndexes = [
                        ...selectedQuestionIndexes,
                        index,
                      ];
                    } else {
                      selectedQuestionIndexes.remove(index);
                    }
                  });
                },
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    SizedBox(
                      width: 300.w,
                      child: Text(
                        faqs[index].question,
                        style: context.text.bodyMedium,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.sp,
                      color: context.colors.onSurface,
                    ),
                    SizedBox(width: 20.w),
                  ],
                ),
              ),
            ),
            if (selectedQuestionIndexes.contains(index))
              model.when(
                data: (data) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 11.5.h,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data.faqAnswers[index].answer,
                          style: context.text.bodyMedium?.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return RetryButton(
                    onRetry: () => ref.invalidate(faqsFutureProvider),
                  );
                },
                loading: () => CustomCircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }

  Widget _renderFaqCategories() {
    return Container(
      width: 362.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(8.r),
      ),
      child: Wrap(
        spacing: 0,
        runSpacing: 0,
        children:
            FAQCategory.values
                .map((e) => _renderCategoryButton(faqCategory: e))
                .toList(),
      ),
    );
  }

  Widget _renderCategoryButton({required FAQCategory faqCategory}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(120.w, 34.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor:
            currentCategory == faqCategory
                ? BLUE_COLOR
                : context.colors.surface,
        side: BorderSide(color: GREY_COLOR, width: 1.w),
        shape: RoundedRectangleBorder(),
      ),
      onPressed: () {
        setState(() {
          currentCategory = faqCategory;
          selectedQuestionIndexes =[];
        });
      },
      child: Text(
        faqCategory.korean,
        style: context.text.bodyMedium?.copyWith(fontSize: 12.sp),
      ),
    );
  }
}
