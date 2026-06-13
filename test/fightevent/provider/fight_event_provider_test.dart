import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_provider.dart';
import 'package:mma_flutter/fight_event/repository/fight_event_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixture/fightevent/upcoming/upcoming_fight_event_fixture.dart';

class _MockFightEventRepo extends Mock implements FightEventRepository {}

String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

void main() {
  late _MockFightEventRepo mockFightEventRepo;
  late ProviderContainer container;

  final dateToFetch = DateTime(2025, 11, 22);
  final key = _dateKey(dateToFetch);
  late List<FightEventModel> upcomingFightEventList;

  setUp(() {
    upcomingFightEventList = [FightEventModel.fromJson(upcomingFightEventJson)];
    mockFightEventRepo = _MockFightEventRepo();
    container = ProviderContainer(
      overrides: [
        fightEventRepositoryProvider.overrideWithValue(mockFightEventRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('fightEventProvider returns correct data when API succeeds', () async {
    when(() => mockFightEventRepo.getSchedule(date: key))
        .thenAnswer((_) async => upcomingFightEventList);

    final result = await container.read(fightEventProvider(key).future);

    expect(result, isNotNull);
    expect(result!.length, upcomingFightEventList.length);
    expect(result.first.id, upcomingFightEventList.first.id);
    verify(() => mockFightEventRepo.getSchedule(date: key)).called(1);
  });

  test('fightEventProvider caches result on repeated reads', () async {
    when(() => mockFightEventRepo.getSchedule(date: key))
        .thenAnswer((_) async => upcomingFightEventList);

    await container.read(fightEventProvider(key).future);
    await container.read(fightEventProvider(key).future);

    verify(() => mockFightEventRepo.getSchedule(date: key)).called(1);
  });

  test('fightEventProvider re-fetches after invalidation', () async {
    when(() => mockFightEventRepo.getSchedule(date: key))
        .thenAnswer((_) async => upcomingFightEventList);

    await container.read(fightEventProvider(key).future);
    container.invalidate(fightEventProvider(key));
    await container.read(fightEventProvider(key).future);

    verify(() => mockFightEventRepo.getSchedule(date: key)).called(2);
  });

  test('fightEventProvider returns null when no event exists for date', () async {
    when(() => mockFightEventRepo.getSchedule(date: key))
        .thenAnswer((_) async => null);

    final result = await container.read(fightEventProvider(key).future);

    expect(result, isNull);
  });

  test('fightEventProvider is in error state when API throws', () async {
    when(() => mockFightEventRepo.getSchedule(date: key))
        .thenThrow(Exception('error'));

    await expectLater(
      container.read(fightEventProvider(key).future),
      throwsA(isA<Exception>()),
    );

    expect(container.read(fightEventProvider(key)), isA<AsyncError>());
  });
}
