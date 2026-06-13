import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/layout/default_layout.dart';
import 'package:mma_flutter/main.dart';

class HomeSplashScreen extends StatelessWidget {
  final bool isUserStateLoading;

  static String get routeName => 'home_splash';

  const HomeSplashScreen({required this.isUserStateLoading, super.key});

  @override
  Widget build(BuildContext context) {
    if(isUserStateLoading) {
      return DefaultLayout(child: _homeSplashScreenBody(context.colors.box));
    }
    return _homeSplashScreenBody(context.colors.box);
  }

  Widget _homeSplashScreenBody(Color color){
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 37.h, bottom: 13.h),
            child: _basicContainer(width: 233.w, height: 18.h,color: color),
          ),
          _basicContainer(width: 293.w, height: 58.h,color: color),
          Padding(
            padding: EdgeInsets.only(top: 36.h, bottom: 33.h),
            child: _basicContainer(width: 45.h, height: 34.w,color: color),
          ),
          _basicContainer(width: 293.w, height: 58.h,color: color),
          Padding(
            padding: EdgeInsets.only(top: 36.h, bottom: 42.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_personShapeWidget(color), _personShapeWidget(color)],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_nameShapeContainer(color), _nameShapeContainer(color)],
          ),
          Padding(
            padding: EdgeInsets.only(top: 26.h, bottom: 10.h),
            child: _basicContainer(width: 205.w, height: 18.h,color: color),
          ),
          _basicContainer(width: 230.w, height: 37.h,color: color),
        ],
      ),
    );
  }

  Container _nameShapeContainer(Color color) {
    return _basicContainer(height: 24.h, width: 162.w,color: color);
  }

  Column _personShapeWidget(Color color) {
    return Column(
      children: [
        Container(
          height: 66.h,
          width: 66.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          height: 58.h,
          width: 138.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32.r),
              bottom: Radius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }

  Container _basicContainer({required double width, required double height,required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: color,
      ),
    );
  }
}
