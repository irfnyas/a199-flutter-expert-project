import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/search_tvs.dart';
import 'package:ditonton/presentation/provider/tv_search_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tv_search_notifier_test.mocks.dart';

@GenerateMocks([SearchTvs])
void main() {
  late TvSearchBloc tvSearchBloc;
  late MockSearchTvs mockSearchTvs;

  final tTvModel = Tv(
    adult: false,
    backdropPath: '/muth4OYamXf41G2evdrLEg8d3om.jpg',
    genreIds: [14, 28],
    id: 557,
    originalName: 'Spider-Man',
    overview:
        'After being bitten by a genetically altered spider, nerdy high school student Peter Parker is endowed with amazing powers to become the Amazing superhero known as Spider-Man.',
    popularity: 60.441,
    posterPath: '/rweIrveL43TaxUN0akQEaAXL6x0.jpg',
    firstAirDate: '2002-05-01',
    name: 'Spider-Man',
    voteAverage: 7.2,
    voteCount: 13507,
  );
  final tTvList = <Tv>[tTvModel];
  final tQuery = 'spiderman';

  setUp(() {
    mockSearchTvs = MockSearchTvs();
    tvSearchBloc = TvSearchBloc(searchTvs: mockSearchTvs);
  });

  group('search tv series', () {
    blocTest<TvSearchBloc, TvSearchState>(
      'emits [TvSearchLoading, TvSearchLoaded] when data is fetched successfully',
      build: () {
        when(mockSearchTvs.execute(tQuery))
            .thenAnswer((_) async => Right(tTvList));
        return tvSearchBloc;
      },
      act: (bloc) => bloc.add(FetchTvSearch(tQuery)),
      expect: () => [
        TvSearchLoading(),
        TvSearchLoaded(tTvList),
      ],
    );

    blocTest<TvSearchBloc, TvSearchState>(
      'emits [TvSearchLoading, TvSearchError] when fetching data fails',
      build: () {
        when(mockSearchTvs.execute(tQuery))
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        return tvSearchBloc;
      },
      act: (bloc) => bloc.add(FetchTvSearch(tQuery)),
      expect: () => [
        TvSearchLoading(),
        TvSearchError('Server Failure'),
      ],
    );
  });

  tearDown(() {
    tvSearchBloc.close();
  });
}
