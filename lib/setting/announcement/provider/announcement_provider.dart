import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/pagination_notifier.dart';
import 'package:mma_flutter/setting/announcement/model/announcement_model.dart';
import 'package:mma_flutter/setting/announcement/repository/announcement_repository.dart';

final announcementContentFutureProvider = FutureProvider.family((ref, int id) {
  final repo = ref.read(announcementRepositoryProvider);
  return repo.getAnnouncementContent(id: id);
},);

final announcementPaginationProvider =
    StateNotifierProvider<AnnouncementPaginationStateNotifier, PaginationBase>((
      ref,
    ) {
      final repo = ref.read(announcementRepositoryProvider);
      return AnnouncementPaginationStateNotifier(repository: repo);
    });

class AnnouncementPaginationStateNotifier
    extends PaginationNotifier<AnnouncementModel, AnnouncementRepository> {
  AnnouncementPaginationStateNotifier({required super.repository});
}
