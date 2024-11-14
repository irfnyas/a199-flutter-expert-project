import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tvs.dart';
import 'package:ditonton/presentation/provider/watchlist_tv_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/dummy_objects.dart';
import 'watchlist_tv_notifier_test.mocks.dart';

@GenerateMocks([GetWatchlistTvs])
void main() {
  late WatchlistTvBloc watchlistTvBloc;
  late MockGetWatchlistTvs mockGetWatchlistTvs;

  setUp(() {
    mockGetWatchlistTvs = MockGetWatchlistTvs();
    watchlistTvBloc = WatchlistTvBloc(getWatchlistTvs: mockGetWatchlistTvs);
  });

  group('watchlist TV', () {
    blocTest<WatchlistTvBloc, WatchlistTvState>(
      'emits [WatchlistTvLoading, WatchlistTvLoaded] when data is fetched successfully',
      build: () {
        when(mockGetWatchlistTvs.execute())
            .thenAnswer((_) async => Right([testWatchlistTv]));
        return watchlistTvBloc;
      },
      act: (bloc) => bloc.add(FetchWatchlistTvs()),
      expect: () => [
        WatchlistTvLoading(),
        WatchlistTvLoaded([testWatchlistTv]),
      ],
    );

    blocTest<WatchlistTvBloc, WatchlistTvState>(
      'emits [WatchlistTvLoading, WatchlistTvError] when fetching data fails',
      build: () {
        when(mockGetWatchlistTvs.execute())
            .thenAnswer((_) async => Left(DatabaseFailure("Can't get data")));
        return watchlistTvBloc;
      },
      act: (bloc) => bloc.add(FetchWatchlistTvs()),
      expect: () => [
        WatchlistTvLoading(),
        WatchlistTvError("Can't get data"),
      ],
    );
  });

  tearDown(() {
    watchlistTvBloc.close();
  });
}
