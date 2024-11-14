import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tvs.dart';
import 'package:ditonton/presentation/provider/top_rated_tvs_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'top_rated_tvs_notifier_test.mocks.dart';

@GenerateMocks([GetTopRatedTvs])
void main() {
  late MockGetTopRatedTvs mockGetTopRatedTvs;
  late TopRatedTvsBloc topRatedTvsBloc;

  setUp(() {
    mockGetTopRatedTvs = MockGetTopRatedTvs();
    topRatedTvsBloc = TopRatedTvsBloc(getTopRatedTvs: mockGetTopRatedTvs);
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

  group('top rated tv series', () {
    blocTest<TopRatedTvsBloc, TopRatedTvsState>(
      'should emit [TopRatedTvsLoading, TopRatedTvsLoaded] when data is loaded successfully',
      build: () {
        when(mockGetTopRatedTvs.execute())
            .thenAnswer((_) async => Right(tTvList));
        return topRatedTvsBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedTvsEvent()),
      expect: () => [
        TopRatedTvsLoading(),
        TopRatedTvsLoaded(tTvList),
      ],
      verify: (_) {
        verify(mockGetTopRatedTvs.execute()).called(1);
      },
    );

    blocTest<TopRatedTvsBloc, TopRatedTvsState>(
      'should emit [TopRatedTvsLoading, TopRatedTvsError] when fetching data fails',
      build: () {
        when(mockGetTopRatedTvs.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return topRatedTvsBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedTvsEvent()),
      expect: () => [
        TopRatedTvsLoading(),
        TopRatedTvsError(tErrorMessage),
      ],
      verify: (_) {
        verify(mockGetTopRatedTvs.execute()).called(1);
      },
    );
  });

  tearDown(() {
    topRatedTvsBloc.close();
  });
}
