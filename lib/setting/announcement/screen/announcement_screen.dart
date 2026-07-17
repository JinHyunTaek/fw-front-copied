import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mma_flutter/common/component/pagination_list_view.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/announcement/model/announcement_model.dart';
import 'package:mma_flutter/setting/announcement/provider/announcement_provider.dart';
import 'package:mma_flutter/setting/announcement/repository/announcement_repository.dart';
import 'package:mma_flutter/setting/announcement/screen/announcement_content_screen.dart';

class AnnouncementScreen extends ConsumerWidget {
  static String get routeName => 'announcement';

  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '공지사항',
          style: context.text.bodyMedium,
        ),
      ),
      body: SafeArea(
        child: PaginationListView<AnnouncementModel, AnnouncementRepository>(
          provider: announcementPaginationProvider,
          itemBuilder: (context, index, model) {
            return SizedBox(
              height: 59.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 24.w,),
                      if (model.pinned)
                        Padding(
                          padding: EdgeInsets.only(right: 14.w),
                          child: Icon(
                            FontAwesomeIcons.thumbtack,
                            color: BLUE_COLOR,
                            size: 20.sp,
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(model.title, style: context.text.bodyMedium),
                          SizedBox(height: 4.h),
                          Text(
                            CustomDateUtils.formatDateWithYear(model.createdDate),
                            style: context.text.bodyMedium?.copyWith(
                              color: LIGHT_GREY_COLOR,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => AnnouncementContentScreen(model: model),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        size: 20.sp,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
