import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mma_flutter/fighter/model/fighter_detail_model.dart';
import 'package:mma_flutter/fighter/provider/fighter_provider.dart';
import 'package:mma_flutter/fighter/repository/fighter_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixture/fighter/fighter_detail_model_json_fixture.dart';

class _MockFighterRepo extends Mock implements FighterRepository {}

void main() {
  late _MockFighterRepo mockFighterRepo;
  late ProviderContainer container;
  late FighterDetailModel fighterDetailModel;

  setUp(() {
    mockFighterRepo = _MockFighterRepo();
    container = ProviderContainer(
      overrides: [fighterRepositoryProvider.overrideWithValue(mockFighterRepo)],
    );
    fighterDetailModel = FighterDetailModel.fromJson(fighterDetailModelJson);
  });

  tearDown(() => container.dispose());

  test('fighterDetailProvider returns correct model when API succeeds', () async {
    final fighterId = fighterDetailModel.id;
    when(() => mockFighterRepo.detail(fighterId: fighterId))
        .thenAnswer((_) async => fighterDetailModel);

    final result = await container.read(fighterDetailProvider(fighterId).future);

    expect(result, equals(fighterDetailModel));
    verify(() => mockFighterRepo.detail(fighterId: fighterId)).called(1);
  });

  test('fighterDetailProvider caches result on repeated reads', () async {
    final fighterId = fighterDetailModel.id;
    when(() => mockFighterRepo.detail(fighterId: fighterId))
        .thenAnswer((_) async => fighterDetailModel);

    await container.read(fighterDetailProvider(fighterId).future);
    await container.read(fighterDetailProvider(fighterId).future);

    verify(() => mockFighterRepo.detail(fighterId: fighterId)).called(1);
  });

  test('fighterDetailProvider re-fetches after invalidation', () async {
    final fighterId = fighterDetailModel.id;
    when(() => mockFighterRepo.detail(fighterId: fighterId))
        .thenAnswer((_) async => fighterDetailModel);

    await container.read(fighterDetailProvider(fighterId).future);
    container.invalidate(fighterDetailProvider(fighterId));
    await container.read(fighterDetailProvider(fighterId).future);

    verify(() => mockFighterRepo.detail(fighterId: fighterId)).called(2);
  });

  test('fighterDetailProvider is in error state when API throws', () async {
    final fighterId = fighterDetailModel.id;
    when(() => mockFighterRepo.detail(fighterId: fighterId))
        .thenThrow(Exception('error'));

    await expectLater(
      container.read(fighterDetailProvider(fighterId).future),
      throwsA(isA<Exception>()),
    );

    expect(container.read(fighterDetailProvider(fighterId)), isA<AsyncError>());
  });
}
