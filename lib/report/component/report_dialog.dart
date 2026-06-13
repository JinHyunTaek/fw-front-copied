import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/report/model/report_request_model.dart';
import 'package:mma_flutter/report/repository/report_repository.dart';

class ReportUserDialog extends ConsumerStatefulWidget {
  final int reportedUserId;
  final String messageId;
  final String messageSnapshot;

  const ReportUserDialog({
    required this.reportedUserId,
    required this.messageId,
    required this.messageSnapshot,
    super.key,
  });

  @override
  ConsumerState<ReportUserDialog> createState() => _ReportUserState();
}

class _ReportUserState extends ConsumerState<ReportUserDialog> {
  ReportCategory? selectedCategory;

  Future<void> _onReport(BuildContext context) async {
    try {
      final res = await ref.read(reportRepositoryProvider).report(
        request: ReportRequestModel(
          reportedUserId: widget.reportedUserId,
          reportCategory: selectedCategory!,
          messageId: widget.messageId,
          messageSnapshot: widget.messageSnapshot,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res ? '신고가 접수되었습니다.' : '이미 신고가 접수된 메시지입니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('탈퇴한 사용자입니다.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text('메시지 신고'),
        content: Column(
          children: ReportCategory.values.map((e) {
            return GestureDetector(
              onTap: () => setState(() {
                selectedCategory = e;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      selectedCategory == e ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                      size: 18,
                      color: selectedCategory == e ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(e.label, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: selectedCategory == null ? null : () => _onReport(context),
            child: Text('신고'),
          ),
        ],
      );
    }

    return AlertDialog(
      backgroundColor: DARK_GREY_COLOR,
      title: Text(
        '메시지 신고',
        style: TextStyle(color: WHITE_COLOR, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ReportCategory.values.map(
          (e) => RadioListTile<ReportCategory>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(e.label, style: TextStyle(color: WHITE_COLOR, fontSize: 14.sp)),
            value: e,
            groupValue: selectedCategory,
            activeColor: Colors.redAccent,
            onChanged: (value) => setState(() => selectedCategory = value),
          ),
        ).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: LIGHT_GREY_COLOR)),
        ),
        TextButton(
          onPressed: selectedCategory == null ? null : () => _onReport(context),
          child: Text('신고', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}
