import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/usecases/tv_save_watchlist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late TvSaveWatchlist usecase;
  late MockTvRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvRepository();
    usecase = TvSaveWatchlist(mockTvRepository);
  });

  test('should save Tv to the repository', () async {
    // arrange
    when(mockTvRepository.saveWatchlist(testTvDetail))
        .thenAnswer((_) async => Right('Added to Watchlist'));
    // act
    final result = await usecase.execute(testTvDetail);
    // assert
    verify(mockTvRepository.saveWatchlist(testTvDetail));
    expect(result, Right('Added to Watchlist'));
  });
}
