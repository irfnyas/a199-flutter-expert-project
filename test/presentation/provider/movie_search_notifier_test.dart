import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:ditonton/presentation/provider/movie_search_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'movie_search_notifier_test.mocks.dart';

@GenerateMocks([SearchMovies])
void main() {
  late MovieSearchBloc movieSearchBloc;
  late MockSearchMovies mockSearchMovies;

  setUp(() {
    mockSearchMovies = MockSearchMovies();
    movieSearchBloc = MovieSearchBloc(searchMovies: mockSearchMovies);
  });

  final tMovieModel = Movie(
    adult: false,
    backdropPath: '/muth4OYamXf41G2evdrLEg8d3om.jpg',
    genreIds: [14, 28],
    id: 557,
    originalTitle: 'Spider-Man',
    overview:
        'After being bitten by a genetically altered spider, nerdy high school student Peter Parker is endowed with amazing powers to become the Amazing superhero known as Spider-Man.',
    popularity: 60.441,
    posterPath: '/rweIrveL43TaxUN0akQEaAXL6x0.jpg',
    releaseDate: '2002-05-01',
    title: 'Spider-Man',
    video: false,
    voteAverage: 7.2,
    voteCount: 13507,
  );
  final tMovieList = <Movie>[tMovieModel];
  final tQuery = 'spiderman';
  const tErrorMessage = 'Server Failure';

  group('search movies', () {
    blocTest<MovieSearchBloc, MovieSearchState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(mockSearchMovies.execute(tQuery))
            .thenAnswer((_) async => Right(tMovieList));
        return movieSearchBloc;
      },
      act: (bloc) => bloc.add(FetchMovieSearch(tQuery)),
      expect: () => [
        MovieSearchLoading(),
        MovieSearchLoaded(tMovieList),
      ],
    );

    blocTest<MovieSearchBloc, MovieSearchState>(
      'should emit [Loading, Error] when data is unsuccessful',
      build: () {
        when(mockSearchMovies.execute(tQuery))
            .thenAnswer((_) async => Left(ServerFailure(tErrorMessage)));
        return movieSearchBloc;
      },
      act: (bloc) => bloc.add(FetchMovieSearch(tQuery)),
      expect: () => [
        MovieSearchLoading(),
        MovieSearchError(tErrorMessage),
      ],
    );
  });

  tearDown(() {
    movieSearchBloc.close();
  });
}
