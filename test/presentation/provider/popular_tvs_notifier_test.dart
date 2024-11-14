import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_popular_tvs.dart';
import 'package:ditonton/presentation/provider/popular_tvs_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'popular_tvs_notifier_test.mocks.dart';

@GenerateMocks([GetPopularTvs])
void main() {
  late MockGetPopularTvs mockGetPopularTvs;
  late PopularTvsBloc popularTvsBloc;

  setUp(() {
    mockGetPopularTvs = MockGetPopularTvs();
    popularTvsBloc = PopularTvsBloc(mockGetPopularTvs);
  });

  final tTv = Tv(
    adult: false,
    backdropPath: 'backdropPath',
    genreIds: [1, 2, 3],
    id: 1,
    originalName: 'originalName',
    overview: 'overview',
    popularity: 1,
    posterPath: 'posterPath',
    firstAirDate: 'firstAirDate',
    name: 'name',
    voteAverage: 1,
    voteCount: 1,
  );

  final tTvList = <Tv>[tTv];
  const tErrorMessage = 'Server Failure';

  group('Popular TV Series', () {
    blocTest<PopularTvsBloc, PopularTvsState>(
      'should emit [PopularTvsLoading, PopularTvsLoaded] when data is loaded successfully',
      build: () {
        when(mockGetPopularTvs.execute())
            .thenAnswer((_) async => Right(tTvList));
        return popularTvsBloc;
      },
      act: (bloc) => bloc.add(FetchPopularTvsEvent()),
      expect: () => [
        PopularTvsLoading(),
        PopularTvsLoaded(tTvList),
      ],
      verify: (_) {
        verify(mockGetPopularTvs.execute()).called(1);
      },
    );

    blocTest<PopularTvsBloc, PopularTvsState>(
      'should emit [PopularTvsLoading, PopularTvsError] when fetching data fails',
      build: () {
        when(mockGetPopularTvs.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return popularTvsBloc;
      },
      act: (bloc) => bloc.add(FetchPopularTvsEvent()),
      expect: () => [
        PopularTvsLoading(),
        PopularTvsError(tErrorMessage),
      ],
      verify: (_) {
        verify(mockGetPopularTvs.execute()).called(1);
      },
    );
  });

  tearDown(() {
    popularTvsBloc.close();
  });
}
