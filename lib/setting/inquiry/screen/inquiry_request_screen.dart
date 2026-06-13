import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_response_model.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_save_request_model.dart';
import 'package:mma_flutter/setting/inquiry/provider/inquiry_provider.dart';
import 'package:mma_flutter/setting/inquiry/repository/inquiry_repository.dart';

class InquiryRequestScreen extends ConsumerStatefulWidget {
  const InquiryRequestScreen({super.key});

  @override
  ConsumerState<InquiryRequestScreen> createState() =>
      _InquiryRequestScreenState();
}

class _InquiryRequestScreenState extends ConsumerState<InquiryRequestScreen> {
  String content = '';
  InquiryCategory? category;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SizedBox(
          width: 362.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _renderInquiryCategories(),
                      SizedBox(height: 12.h),

                      TextField(
                        onChanged: (val) {
                          setState(() {
                            content = val;
                          });
                        },
                        style: TextStyle(color: WHITE_COLOR),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                            left: 16.w,
                            bottom: 10.h,
                            top: 10.h,
                          ),
                          filled: true,
                          fillColor: context.colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: WHITE_COLOR),
                          ),
                          hintText: '문의 내용을 10자 이상 적어주세요',
                          hintStyle: TextStyle(
                            color: MID_GREY_COLOR,
                            fontSize: 12.sp,
                          ),
                        ),
                        maxLines: 10,
                        cursorColor: WHITE_COLOR,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: OutlinedButton(
                  onPressed:
                      category == null || content.trim().isEmpty || content.trim().length < 10
                          ? null
                          : () async {
                            final notifier = ref.read(
                              inquirySubmitProvider.notifier,
                            );
                            notifier.state = const AsyncValue.loading();
                            final res = await AsyncValue.guard(() {
                              return ref
                                  .read(inquiryRepositoryProvider)
                                  .save(
                                    request: InquirySaveRequestModel(
                                      category: category!,
                                      content: content,
                                    ),
                                  );
                            });
                            notifier.state = res;
                            res.whenOrNull(
                              data: (data) {
                                ref.invalidate(inquiryPaginationProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '문의가 정상적으로 접수되었습니다. 고객센터의 응답을 기다려주세요',
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                              error: (error, stackTrace) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('알 수 없는 오류 발생')),
                                );
                              },
                            );
                          },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: BLUE_COLOR,
                    disabledBackgroundColor: MID_GREY_COLOR,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8.r),
                    ),
                  ),
                  child: Text('문의하기', style: context.text.bodyMedium?.copyWith(
                    color: WHITE_COLOR
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderInquiryCategories() {
    return DropdownMenuTheme(
      data: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(context.colors.surface),
          side: WidgetStatePropertyAll(
            BorderSide(color: GREY_COLOR, width: 1.w),
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
            ),
          ),
        ),
        textStyle: defaultTextStyle.copyWith(
          fontSize: 12.sp,
          color: Colors.white,
        ),
      ),
      child: DropdownMenu<InquiryCategory>(
        width: 362.w,
        hintText: '문의 유형 선택하기',
        trailingIcon: Icon(
          Icons.keyboard_arrow_down,
          color: WHITE_COLOR,
          size: 20.r,
        ),
        selectedTrailingIcon: Icon(
          Icons.keyboard_arrow_up,
          color: WHITE_COLOR,
          size: 20.r,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: context.colors.subText,
          hintStyle: defaultTextStyle,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
          isDense: true,
        ),
        dropdownMenuEntries:
            InquiryCategory.values
                .map(
                  (e) => DropdownMenuEntry(
                    value: e,
                    label: e.korean,
                    labelWidget: Text(e.korean, style: context.text.bodyMedium),
                  ),
                )
                .toList(),
        onSelected: (value) {
          category = value;
        },
      ),
    );
  }
}
