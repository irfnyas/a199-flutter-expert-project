import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tvs.dart';
import 'package:ditonton/domain/usecases/get_popular_tvs.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tvs.dart';
import 'package:ditonton/presentation/provider/tv_list_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tv_list_notifier_test.mocks.dart';

@GenerateMocks([GetNowPlayingTvs, GetPopularTvs, GetTopRatedTvs])
void main() {
  late TvListBloc tvListBloc;
  late MockGetNowPlayingTvs mockGetNowPlayingTvs;
  late MockGetPopularTvs mockGetPopularTvs;
  late MockGetTopRatedTvs mockGetTopRatedTvs;

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

  setUp(() {
    mockGetNowPlayingTvs = MockGetNowPlayingTvs();
    mockGetPopularTvs = MockGetPopularTvs();
    mockGetTopRatedTvs = MockGetTopRatedTvs();
    tvListBloc = TvListBloc(
      getNowPlayingTvs: mockGetNowPlayingTvs,
      getPopularTvs: mockGetPopularTvs,
      getTopRatedTvs: mockGetTopRatedTvs,
    );
  });

  group('now playing tv series', () {
    blocTest<TvListBloc, TvListState>(
      'emits [TvListLoading, TvListLoaded] when data is fetched successfully',
      build: () {
        when(mockGetNowPlayingTvs.execute())
            .thenAnswer((_) async => Right(tTvList));
        return tvListBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingTvs()),
      expect: () => [
        TvListLoading(),
        TvListLoaded(nowPlayingTvs: tTvList),
      ],
    );

    blocTest<TvListBloc, TvListState>(
      'emits [TvListLoading, TvListError] when fetching data fails',
      build: () {
        when(mockGetNowPlayingTvs.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return tvListBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingTvs()),
      expect: () => [
        TvListLoading(),
        TvListError(tErrorMessage),
      ],
    );
  });

  group('FetchPopularTvs', () {
    blocTest<TvListBloc, TvListState>(
      'emits [TvListLoading, TvListLoaded] when data is fetched successfully',
      build: () {
        when(mockGetPopularTvs.execute())
            .thenAnswer((_) async => Right(tTvList));
        return tvListBloc;
      },
      act: (bloc) => bloc.add(FetchPopularTvs()),
      expect: () => [
        TvListLoading(),
        TvListLoaded(popularTvs: tTvList),
      ],
    );

    blocTest<TvListBloc, TvListState>(
      'emits [TvListLoading, TvListError] when fetching data fails',
      build: () {
        when(mockGetPopularTvs.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return tvListBloc;
      },
      act: (bloc) => bloc.add(FetchPopularTvs()),
      expect: () => [
        TvListLoading(),
        TvListError(tErrorMessage),
      ],
    );
  });

  group('FetchTopRatedTvs', () {
    blocTest<TvListBloc, TvListState>(
      'emits [TvListLoading, TvListLoaded] when data is fetched successfully',
      build: () {
        when(mockGetTopRatedTvs.execute())
            .thenAnswer((_) async => Right(tTvList));
        return tvListBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedTvs()),
      expect: () => [
        TvListLoading(),
        TvListLoaded(topRatedTvs: tTvList),
      ],
    );

    blocTest<TvListBloc, TvListState>(
      'emits [TvListLoading, TvListError] when fetching data fails',
      build: () {
        when(mockGetTopRatedTvs.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return tvListBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedTvs()),
      expect: () => [
        TvListLoading(),
        TvListError(tErrorMessage),
      ],
    );
  });

  tearDown(() {
    tvListBloc.close();
  });
}
