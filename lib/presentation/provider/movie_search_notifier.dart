import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/search_movies.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class MovieSearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchMovieSearch extends MovieSearchEvent {
  final String query;

  FetchMovieSearch(this.query);

  @override
  List<Object> get props => [query];
}

// States
abstract class MovieSearchState extends Equatable {
  @override
  List<Object> get props => [];
}

class MovieSearchEmpty extends MovieSearchState {}

class MovieSearchLoading extends MovieSearchState {}

class MovieSearchLoaded extends MovieSearchState {
  final List<Movie> movies;

  MovieSearchLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class MovieSearchError extends MovieSearchState {
  final String message;

  MovieSearchError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  final SearchMovies searchMovies;

  MovieSearchBloc({required this.searchMovies}) : super(MovieSearchEmpty()) {
    on<FetchMovieSearch>((event, emit) async {
      emit(MovieSearchLoading());
      final result = await searchMovies.execute(event.query);

      result.fold(
        (failure) => emit(MovieSearchError(failure.message)),
        (movies) => emit(MovieSearchLoaded(movies)),
      );
    });
  }
}
