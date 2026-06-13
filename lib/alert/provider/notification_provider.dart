import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/alert/model/update_preference_request.dart';
import 'package:mma_flutter/alert/model/user_preferences.dart';
import 'package:mma_flutter/alert/repository/alert_repository.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';

final notificationProvider =
    StateNotifierProvider.autoDispose<NotificationStateNotifier, StateBase<UserPreferences>>((
      ref,
    ) {
      final alertRepository = ref.read(alertRepositoryProvider);
      return NotificationStateNotifier(alertRepository: alertRepository);
    });

class NotificationStateNotifier extends StateNotifier<StateBase<UserPreferences>> {
  final AlertRepository alertRepository;

  NotificationStateNotifier({required this.alertRepository}) : super(StateLoading()) {
    getPreferences();
  }

  Future<void> getPreferences() async {
    try {
      state = StateLoading();
      final resp = await alertRepository.preferences();
      state = StateData(data: resp);
    } on Exception catch (e, stack) {
      log('$e');
      log('$stack');
      state = StateError(message: '푸시 알림 데이터 불러오기 중 오류 발생');
    }
  }

  Future<void> updateSinglePreference({
    required UpdatePreferenceRequest request,
    required UserPreferences currentPreferences
  }) async {
    state = StateData(
      data: currentPreferences.copyWithUpdateRequest(request: request),
    );
    try {
      await alertRepository.updateSinglePreference(request: request);
    } on Exception {
      state = StateError(message: '푸시 알림 설정 중 문제 발생');
    }
  }

  Future<void> updatePreferences({required bool isOn}) async {
    state = StateData(
      data: UserPreferences(
        eventAlertEnabled: isOn,
        fighterAlertEnabled: isOn,
        weeklyEventAlertEnabled: isOn,
      ),
    );
    try {
      await alertRepository.updateAllPreferences(isOn: isOn);
    } on Exception {
      state = StateError(message: '푸시 알림 설정 중 문제 발생');
    }
  }
}
