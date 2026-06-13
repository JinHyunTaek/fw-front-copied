import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/announcement/model/announcement_model.dart';
import 'package:mma_flutter/setting/announcement/provider/announcement_provider.dart';

class AnnouncementContentScreen extends ConsumerWidget {
  static String get routeName => 'announcement-content';

  final AnnouncementModel model;

  const AnnouncementContentScreen({required this.model, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(announcementContentFutureProvider(model.id));
    return content.when(
      data: (data) {
        return _frame(
          context,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: SizedBox(
                  width: 362.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text(
                        model.title,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          CustomDateUtils.formatDate(model.createdDate),
                          style: TextStyle(
                            color: LIGHT_GREY_COLOR,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Text(data.content, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return _frame(
          context,
          body: RetryButton(
            onRetry: () => ref.invalidate(announcementContentFutureProvider),
          ),
        );
      },
      loading: () {
        return _frame(context, body: CustomCircularProgressIndicator());
      },
    );
  }

  Widget _frame(BuildContext context, {required Widget body}) {
    return Scaffold(
      body: body,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '공지사항 상세',
          style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: context.colors.surface,
    );
  }
}
