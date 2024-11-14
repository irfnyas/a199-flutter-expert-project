import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tvs.dart';
import 'package:ditonton/presentation/provider/now_playing_tvs_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'now_playing_tvs_notifier_test.mocks.dart';

@GenerateMocks([GetNowPlayingTvs])
void main() {
  late MockGetNowPlayingTvs mockGetNowPlayingTvs;
  late NowPlayingTvsBloc nowPlayingTvsBloc;

  setUp(() {
    mockGetNowPlayingTvs = MockGetNowPlayingTvs();
    nowPlayingTvsBloc = NowPlayingTvsBloc(mockGetNowPlayingTvs);
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

  group('now playing tv series', () {
    blocTest<NowPlayingTvsBloc, NowPlayingTvsState>(
      'should emit [NowPlayingTvsLoading, NowPlayingTvsLoaded] when data is gotten successfully',
      build: () {
        when(mockGetNowPlayingTvs.execute())
            .thenAnswer((_) async => Right(tTvList));
        return nowPlayingTvsBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingTvsEvent()),
      expect: () => [
        NowPlayingTvsLoading(),
        NowPlayingTvsLoaded(tTvList),
      ],
      verify: (bloc) {
        verify(mockGetNowPlayingTvs.execute());
      },
    );

    blocTest<NowPlayingTvsBloc, NowPlayingTvsState>(
      'should emit [NowPlayingTvsLoading, NowPlayingTvsError] when getting data fails',
      build: () {
        when(mockGetNowPlayingTvs.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return nowPlayingTvsBloc;
      },
      act: (bloc) => bloc.add(FetchNowPlayingTvsEvent()),
      expect: () => [
        NowPlayingTvsLoading(),
        NowPlayingTvsError(tErrorMessage),
      ],
      verify: (bloc) {
        verify(mockGetNowPlayingTvs.execute());
      },
    );
  });

  tearDown(() {
    nowPlayingTvsBloc.close();
  });
}
