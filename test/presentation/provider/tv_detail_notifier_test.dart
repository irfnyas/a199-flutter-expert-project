import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/domain/usecases/get_tv_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_recommendations.dart';
import 'package:ditonton/domain/usecases/get_tv_watchlist_status.dart';
import 'package:ditonton/domain/usecases/tv_remove_watchlist.dart';
import 'package:ditonton/domain/usecases/tv_save_watchlist.dart';
import 'package:ditonton/presentation/provider/tv_detail_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import 'tv_detail_notifier_test.mocks.dart';

@GenerateMocks([
  GetTvDetail,
  GetTvRecommendations,
  GetTvWatchListStatus,
  TvSaveWatchlist,
  TvRemoveWatchlist,
])
void main() {
  late TvDetailBloc tvDetailBloc;
  late MockGetTvDetail mockGetTvDetail;
  late MockGetTvRecommendations mockGetTvRecommendations;
  late MockGetTvWatchListStatus mockGetTvWatchlistStatus;
  late MockTvSaveWatchlist mockTvSaveWatchlist;
  late MockTvRemoveWatchlist mockTvRemoveWatchlist;
  final tId = 1;

  setUp(() {
    mockGetTvDetail = MockGetTvDetail();
    mockGetTvRecommendations = MockGetTvRecommendations();
    mockGetTvWatchlistStatus = MockGetTvWatchListStatus();
    mockTvSaveWatchlist = MockTvSaveWatchlist();
    mockTvRemoveWatchlist = MockTvRemoveWatchlist();
    tvDetailBloc = TvDetailBloc(
      getTvDetail: mockGetTvDetail,
      getTvRecommendations: mockGetTvRecommendations,
      getTvWatchListStatus: mockGetTvWatchlistStatus,
      tvSaveWatchlist: mockTvSaveWatchlist,
      tvRemoveWatchlist: mockTvRemoveWatchlist,
    );
  });

  group('Get TV Detail', () {
    blocTest<TvDetailBloc, TvDetailState>(
      'emits [TvDetailLoading, TvDetailLoaded] when data is fetched successfully',
      build: () {
        when(mockGetTvDetail.execute(tId))
            .thenAnswer((_) async => Right(testTvDetail));
        when(mockGetTvRecommendations.execute(tId))
            .thenAnswer((_) async => Right(testTvList));
        when(mockGetTvWatchlistStatus.execute(tId))
            .thenAnswer((_) async => true);
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(FetchTvDetail(tId)),
      expect: () => [
        TvDetailLoading(),
        TvDetailLoaded(testTvDetail, testTvList, true),
      ],
    );
  });

  group('Watchlist', () {
    blocTest<TvDetailBloc, TvDetailState>(
      'emits [TvDetailAddRemoveSuccess] when adding to watchlist is successful',
      build: () {
        when(mockTvSaveWatchlist.execute(testTvDetail))
            .thenAnswer((_) async => Right('Added to Watchlist'));
        when(mockGetTvDetail.execute(testTvDetail.id))
            .thenAnswer((_) async => Right(testTvDetail));
        when(mockGetTvRecommendations.execute(testTvDetail.id))
            .thenAnswer((_) async => Right(testTvList));
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(AddToWatchlist(testTvDetail)),
      expect: () => [
        TvDetailAddRemoveSuccess(
            testTvDetail, testTvList, true, 'Added to Watchlist'),
      ],
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'emits [TvDetailAddRemoveSuccess] when removing from watchlist is successful',
      build: () {
        when(mockTvRemoveWatchlist.execute(testTvDetail))
            .thenAnswer((_) async => Right('Removed from Watchlist'));
        when(mockGetTvDetail.execute(testTvDetail.id))
            .thenAnswer((_) async => Right(testTvDetail));
        when(mockGetTvRecommendations.execute(testTvDetail.id))
            .thenAnswer((_) async => Right(testTvList));
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(RemoveFromWatchlist(testTvDetail)),
      expect: () => [
        TvDetailAddRemoveSuccess(
            testTvDetail, testTvList, false, 'Removed from Watchlist'),
      ],
    );
  });

  tearDown(() {
    tvDetailBloc.close();
  });
}
