import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:ditonton/presentation/provider/top_rated_movies_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'top_rated_movies_notifier_test.mocks.dart';

@GenerateMocks([GetTopRatedMovies])
void main() {
  late MockGetTopRatedMovies mockGetTopRatedMovies;
  late TopRatedMoviesBloc topRatedMoviesBloc;

  setUp(() {
    mockGetTopRatedMovies = MockGetTopRatedMovies();
    topRatedMoviesBloc =
        TopRatedMoviesBloc(getTopRatedMovies: mockGetTopRatedMovies);
  });

  final tMovie = Movie(
    adult: false,
    backdropPath: 'backdropPath',
    genreIds: [1, 2, 3],
    id: 1,
    originalTitle: 'originalTitle',
    overview: 'overview',
    popularity: 1,
    posterPath: 'posterPath',
    releaseDate: 'releaseDate',
    title: 'title',
    video: false,
    voteAverage: 1,
    voteCount: 1,
  );

  final tMovieList = <Movie>[tMovie];
  const tErrorMessage = 'Server Failure';

  group('top rated movies', () {
    blocTest<TopRatedMoviesBloc, TopRatedMoviesState>(
      'should emit [TopRatedMoviesLoading, TopRatedMoviesLoaded] when data is loaded successfully',
      build: () {
        when(mockGetTopRatedMovies.execute())
            .thenAnswer((_) async => Right(tMovieList));
        return topRatedMoviesBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedMoviesEvent()),
      expect: () => [
        TopRatedMoviesLoading(),
        TopRatedMoviesLoaded(tMovieList),
      ],
      verify: (_) {
        verify(mockGetTopRatedMovies.execute()).called(1);
      },
    );

    blocTest<TopRatedMoviesBloc, TopRatedMoviesState>(
      'should emit [TopRatedMoviesLoading, TopRatedMoviesError] when fetching data fails',
      build: () {
        when(mockGetTopRatedMovies.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return topRatedMoviesBloc;
      },
      act: (bloc) => bloc.add(FetchTopRatedMoviesEvent()),
      expect: () => [
        TopRatedMoviesLoading(),
        TopRatedMoviesError(tErrorMessage),
      ],
      verify: (_) {
        verify(mockGetTopRatedMovies.execute()).called(1);
      },
    );
  });

  tearDown(() {
    topRatedMoviesBloc.close();
  });
}
