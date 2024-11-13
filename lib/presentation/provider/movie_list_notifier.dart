import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/usecases/get_now_playing_movies.dart';
import 'package:ditonton/domain/usecases/get_popular_movies.dart';
import 'package:ditonton/domain/usecases/get_top_rated_movies.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class MovieListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchNowPlayingMovies extends MovieListEvent {}

class FetchPopularMovies extends MovieListEvent {}

class FetchTopRatedMovies extends MovieListEvent {}

// States
abstract class MovieListState extends Equatable {
  @override
  List<Object> get props => [];
}

class MovieListEmpty extends MovieListState {}

class MovieListLoading extends MovieListState {}

class MovieListLoaded extends MovieListState {
  final List<Movie> nowPlayingMovies;
  final List<Movie> popularMovies;
  final List<Movie> topRatedMovies;

  MovieListLoaded({
    this.nowPlayingMovies = const [],
    this.popularMovies = const [],
    this.topRatedMovies = const [],
  });

  @override
  List<Object> get props => [nowPlayingMovies, popularMovies, topRatedMovies];
}

class MovieListError extends MovieListState {
  final String message;

  MovieListError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final GetNowPlayingMovies getNowPlayingMovies;
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;

  List<Movie> nowPlayingMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];

  MovieListBloc({
    required this.getNowPlayingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
  }) : super(MovieListEmpty()) {
    on<FetchNowPlayingMovies>((event, emit) async {
      emit(MovieListLoading());
      final result = await getNowPlayingMovies.execute();
      result.fold(
        (failure) => emit(MovieListError(failure.message)),
        (movies) {
          nowPlayingMovies = movies;
          emit(MovieListLoaded(
            nowPlayingMovies: nowPlayingMovies,
            popularMovies: popularMovies,
            topRatedMovies: topRatedMovies,
          ));
        },
      );
    });

    on<FetchPopularMovies>((event, emit) async {
      emit(MovieListLoading());
      final result = await getPopularMovies.execute();
      result.fold(
        (failure) => emit(MovieListError(failure.message)),
        (movies) {
          popularMovies = movies;
          emit(MovieListLoaded(
            nowPlayingMovies: nowPlayingMovies,
            popularMovies: popularMovies,
            topRatedMovies: topRatedMovies,
          ));
        },
      );
    });

    on<FetchTopRatedMovies>((event, emit) async {
      emit(MovieListLoading());
      final result = await getTopRatedMovies.execute();
      result.fold(
        (failure) => emit(MovieListError(failure.message)),
        (movies) {
          topRatedMovies = movies;
          emit(MovieListLoaded(
            nowPlayingMovies: nowPlayingMovies,
            popularMovies: popularMovies,
            topRatedMovies: topRatedMovies,
          ));
        },
      );
    });
  }
}
