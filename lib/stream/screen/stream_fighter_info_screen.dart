import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_detail_stat.dart';
import 'package:mma_flutter/fight_event/component/stat/fighter_fight_event_name_versus_name.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/fighter_fight_event_detail_model.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';

class FighterInfoScreen extends StatelessWidget {
  final FighterFightEventFighterModel f1;
  final FighterFightEventFighterModel f2;

  const FighterInfoScreen({required this.f1, required this.f2, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: context.colors.box,
        child: SingleChildScrollView(
          physics: Platform.isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 25.h),
                  child: Text(
                    '선수 프로필',
                    style: context.text.bodyMedium?.copyWith(
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              FighterFightEventNameVersusName(winner: f1, loser: f2),
              SizedBox(height: 39.h),
              FighterFightEventDetailStat(winner: f1, loser: f2),
            ],
          ),
        ),
      ),
    );
  }
}
