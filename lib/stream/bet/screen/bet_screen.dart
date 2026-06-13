import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/point_with_icon.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/component/bet_alert_dialog.dart';
import 'package:mma_flutter/stream/bet/component/bet_create_card.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/stream/bet/utils/prediction_reward_policy.dart';
import 'package:mma_flutter/stream/bet/utils/profit_calculator.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class BetScreen extends ConsumerWidget {
  final TabController tabController;
  final bool betAvailable;

  const BetScreen({
    required this.tabController,
    required this.betAvailable,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betList = ref.watch(betCardProvider);

    final userBase = ref.watch(userProvider);
    if (userBase is! UserModel) return const SizedBox.shrink();
    final user = userBase;

    if (!betAvailable) {
      return Container(
        color: context.colors.box,
        child: Center(
          child: Text(
            '경기가 임박한 주말에는 예측이 마감돼요.\n다음 이벤트가 열리면 다시 예측할 수 있어요.',
            style: context.text.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (betList.isEmpty) {
      return Container(
        color: context.colors.box,
        child: Center(
          child: Text(
            'CARDS 탭에서 예측하실 카드를 선택하세요',
            style: context.text.bodyLarge,
          ),
        ),
      );
    }

    final totalEntryFee = PredictionRewardPolicy.entryFee * betList.length;
    final canSubmit = _isAllValid(user: user, betList: betList);

    return SafeArea(
      child: Container(
        color: context.colors.box,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 6.h, right: 20.w),
                child: PointWithIcon(point: user.point),
              ),
              Center(
                child: Text(
                  '다음 경기의 승자는?',
                  style: context.text.bodyMedium?.copyWith(fontSize: 17.sp),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.h, bottom: 6.h, right: 20.w),
                child: GestureDetector(
                  onTap: () => _showScoreGuide(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '점수 가중치 ',
                        style: defaultTextStyle.copyWith(
                          color: context.colors.onSurface,
                          fontSize: 12.sp,
                        ),
                      ),
                      Icon(
                        Icons.help_outline_sharp,
                        color: context.colors.onSurface,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              ...betList.mapIndexed(
                (index, betState) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: BetCreateCard(
                    betState: betState,
                    user: user,
                    index: index,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 15.h, bottom: 8.h),
                  child: SizedBox(
                    width: 362.w,
                    child: _buildEntryFeeBox(
                      context: context,
                      cardCount: betList.length,
                      totalEntryFee: totalEntryFee,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: SizedBox(
                    width: 362.w,
                    child: _buildStatus(
                      context: context,
                      user: user,
                      betList: betList,
                      totalEntryFee: totalEntryFee,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 18.h),
                  child: SizedBox(
                    width: 127.w,
                    height: 31.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: canSubmit ? BLUE_COLOR : GREY_COLOR,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed:
                          canSubmit
                              ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return BetAlertDialog(
                                      tabController: tabController,
                                    );
                                  },
                                );
                              }
                              : null,
                      child: Text('예측하기', style: defaultTextStyle),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryFeeBox({
    required BuildContext context,
    required int cardCount,
    required int totalEntryFee,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: GREY_COLOR, width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PointWithIcon(point: totalEntryFee),
          Text(' 사용', style: context.text.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildStatus({
    required BuildContext context,
    required UserModel user,
    required List<BetState> betList,
    required int totalEntryFee,
  }) {
    if (totalEntryFee > user.point) {
      return _statusText('포인트가 부족합니다', isError: true);
    }

    final allCardsConfigured = betList.every(
      (s) =>
          (s.card.myWinner != null && s.card.myLoser != null) ||
          s.card.drawSelected,
    );
    if (!allCardsConfigured) {
      return _statusText('각 카드의 승자 또는 무승부를 선택해주세요', isError: true);
    }

    final exp = ProfitCalculator.calculateTotalProfit(
      betCards: betList.map((s) => s.card).toList(),
    );
    final formatted = NumberFormat('#,###').format(exp);
    return _statusText('예측 적중 시 획득 점수: $formatted EXP', isError: false);
  }

  Widget _statusText(String message, {required bool isError}) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 12.sp,
        color: isError ? Colors.red : Colors.green,
      ),
    );
  }

  bool _isAllValid({required UserModel user, required List<BetState> betList}) {
    if (betList.isEmpty) return false;
    final totalEntryFee = PredictionRewardPolicy.entryFee * betList.length;
    if (totalEntryFee > user.point) return false;
    return betList.every(
      (s) =>
          (s.card.myWinner != null && s.card.myLoser != null) ||
          s.card.drawSelected,
    );
  }

  void _showScoreGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ScoreGuideDialog(),
    );
  }
}

class _ScoreGuideDialog extends StatelessWidget {
  const _ScoreGuideDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.box,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
      contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      actionsPadding: EdgeInsets.only(bottom: 8.h, right: 8.w),
      title: Text(
        '점수 가중치 안내',
        style: context.text.bodyMedium?.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _entryFeeBlock(context),
            SizedBox(height: 16.h),
            _sectionHeader(context, '획득 점수 (적중 시 가산)'),
            SizedBox(height: 6.h),
            _scoreRow(context, '승자 적중', '+${PredictionRewardPolicy.winnerHit}'),
            _scoreRow(
              context,
              '무승부 적중',
              '+${_format(PredictionRewardPolicy.drawHit)}',
            ),
            _scoreRow(
              context,
              'KO/TKO/서브미션 적중',
              '+${PredictionRewardPolicy.winMethodKoTkoSubHit}',
            ),
            _scoreRow(
              context,
              '판정 적중',
              '+${PredictionRewardPolicy.winMethodDecHit}',
            ),
            _scoreRow(
              context,
              '피니시 라운드 적중',
              '+${PredictionRewardPolicy.finishRoundHit}',
            ),
            _scoreRow(
              context,
              '파이트 오브 더 나잇 적중',
              '+${PredictionRewardPolicy.fotnHit}',
            ),
            _scoreRow(
              context,
              '퍼포먼스 오브 더 나잇 적중',
              '+${PredictionRewardPolicy.potnHit}',
            ),
            SizedBox(height: 16.h),
            _sectionHeader(context, '풀옵션 보너스'),
            SizedBox(height: 6.h),
            Text(
              '승자 + 승리 방식 + 피니시 라운드 + \n파이트/퍼포먼스 오브 더 나잇을 모두 적중하면\n +${PredictionRewardPolicy.fullOptionBonus}점 추가',
              style: _bodyStyle(context),
            ),
            SizedBox(height: 16.h),
            _sectionHeader(context, '조합 예측 보너스'),
            SizedBox(height: 6.h),
            Text(
              '2장 이상의 조합 예측을 모두 적중하면\n카드별 적중 옵션 1개당 +${PredictionRewardPolicy.comboBonusPerOption}점 추가',
              style: _bodyStyle(context),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            fixedSize: Size(48.w, 26.h),
            backgroundColor: context.colors.box,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '닫기',
            style: context.text.bodySmall?.copyWith(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _entryFeeBlock(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '참가 포인트',
            style: context.text.bodyMedium?.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '예측 1건당 ${PredictionRewardPolicy.entryFee}P (취소 시 환불)',
            style: _bodyStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label) {
    return Text(
      label,
      style: context.text.bodyMedium?.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _scoreRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('· ', style: _bodyStyle(context)),
          Expanded(child: Text(label, style: _bodyStyle(context))),
          SizedBox(width: 8.w),
          Text(
            value,
            style: _bodyStyle(context)?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  TextStyle? _bodyStyle(BuildContext context) =>
      context.text.bodyMedium?.copyWith(fontSize: 12.sp, height: 1.4);

  String _format(int v) {
    if (v < 1000) return '$v';
    return v.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
