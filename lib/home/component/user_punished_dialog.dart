import 'package:flutter/cupertino.dart';
import 'package:mma_flutter/common/component/custom_alert_dialog.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/report/model/report_request_model.dart';

class UserPunishedDialog extends StatelessWidget {
  final ReportCategory reason;
  final DateTime restrictEndAt;

  const UserPunishedDialog({
    required this.reason,
    required this.restrictEndAt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      titleMsg: '알림',
      contentMsg:
      '${reason.label} 사유로 채팅 이용이 7일간 제한되었습니다.\n'
          '해제 예정 시각: ${CustomDateUtils.formatDateTime(restrictEndAt)}',
    );
  }
}
