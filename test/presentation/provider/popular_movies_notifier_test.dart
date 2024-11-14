import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/presentation/provider/popular_movies_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'popular_movies_notifier_test.mocks.dart';

@GenerateMocks([GetPopularMovies])
void main() {
  late MockGetPopularMovies mockGetPopularMovies;
  late PopularMoviesBloc popularMoviesBloc;

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    popularMoviesBloc = PopularMoviesBloc(mockGetPopularMovies);
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

  group('popular movies', () {
    blocTest<PopularMoviesBloc, PopularMoviesState>(
      'should emit [PopularMoviesLoading, PopularMoviesLoaded] when data is loaded successfully',
      build: () {
        when(mockGetPopularMovies.execute())
            .thenAnswer((_) async => Right(tMovieList));
        return popularMoviesBloc;
      },
      act: (bloc) => bloc.add(FetchPopularMoviesEvent()),
      expect: () => [
        PopularMoviesLoading(),
        PopularMoviesLoaded(tMovieList),
      ],
      verify: (_) {
        verify(mockGetPopularMovies.execute()).called(1);
      },
    );

    blocTest<PopularMoviesBloc, PopularMoviesState>(
      'should emit [PopularMoviesLoading, PopularMoviesError] when fetching data fails',
      build: () {
        when(mockGetPopularMovies.execute())
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return popularMoviesBloc;
      },
      act: (bloc) => bloc.add(FetchPopularMoviesEvent()),
      expect: () => [
        PopularMoviesLoading(),
        PopularMoviesError(tErrorMessage),
      ],
      verify: (_) {
        verify(mockGetPopularMovies.execute()).called(1);
      },
    );
  });

  tearDown(() {
    popularMoviesBloc.close();
  });
}
