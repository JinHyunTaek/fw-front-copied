import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/event/common/dto/event_card_model.dart';
import 'package:mma_flutter/event/common/repository/event_repository.dart';

final activeEventsProvider = FutureProvider<EventCardsModel>((ref) async {
  return ref.read(eventRepositoryProvider).getActiveEvents();
});
