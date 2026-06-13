import 'dart:ui';

import 'package:mma_flutter/common/const/colors.dart';

Color renderBetButtonBackGroundColor({
  required int index,
  required Color mainColor,
  required int? selectedIndex,
}) {
  return selectedIndex == index ? mainColor : DARK_GREY_COLOR;
}
