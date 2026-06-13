import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/game/model/image_game_response_model.dart';
import 'package:mma_flutter/game/model/name_game_response_model.dart';
import 'package:mma_flutter/main.dart';

class GameTextQuestion extends StatelessWidget {
  final String question;
  final bool isFightGame;

  const GameTextQuestion({
    required this.question,
    required this.isFightGame,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('asset/img/component/black.png'),
          Text(
            question,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isFightGame ? 14.sp : 20.sp,
              color: WHITE_COLOR,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
