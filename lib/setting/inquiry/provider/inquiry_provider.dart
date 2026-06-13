import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/provider/pagination_notifier.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_response_model.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_save_request_model.dart';
import 'package:mma_flutter/setting/inquiry/repository/inquiry_repository.dart';

final inquiryBodyFutureProvider = FutureProvider.family((ref, int id) {
  final repo = ref.read(inquiryRepositoryProvider);
  return repo.getBody(inquiryId: id);
});

final inquirySubmitProvider = StateProvider<AsyncValue<void>>(
  (ref) => const AsyncValue.data(null),
);

final inquiryPaginationProvider = StateNotifierProvider((ref) {
  final repo = ref.read(inquiryRepositoryProvider);
  return InquiryPaginationStateNotifier(repository: repo);
});

class InquiryPaginationStateNotifier
    extends PaginationNotifier<InquiryResponseModel, InquiryRepository> {
  InquiryPaginationStateNotifier({required super.repository});
}
