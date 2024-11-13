import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class MovieDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movie;
  final List<Movie> recommendations;
  final bool isAddedToWatchlist;

  MovieDetailLoaded(this.movie, this.recommendations, this.isAddedToWatchlist);

  @override
  List<Object?> get props => [movie, recommendations, isAddedToWatchlist];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  MovieDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class MovieDetailAddRemoveSuccess extends MovieDetailState {
  final MovieDetail movie;
  final List<Movie> recommendations;
  final bool isAddedToWatchlist;
  final String message;

  MovieDetailAddRemoveSuccess(
    this.movie,
    this.recommendations,
    this.isAddedToWatchlist,
    this.message,
  );

  @override
  List<Object?> get props =>
      [movie, recommendations, isAddedToWatchlist, message];
}

// Events
abstract class MovieDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMovieDetail extends MovieDetailEvent {
  final int id;

  FetchMovieDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddToWatchlist extends MovieDetailEvent {
  final MovieDetail movie;

  AddToWatchlist(this.movie);

  @override
  List<Object?> get props => [movie];
}

class RemoveFromWatchlist extends MovieDetailEvent {
  final MovieDetail movie;

  RemoveFromWatchlist(this.movie);

  @override
  List<Object?> get props => [movie];
}

// Bloc
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetMovieDetail getMovieDetail;
  final GetMovieRecommendations getMovieRecommendations;
  final GetWatchListStatus getWatchListStatus;
  final SaveWatchlist saveWatchlist;
  final RemoveWatchlist removeWatchlist;

  MovieDetailBloc({
    required this.getMovieDetail,
    required this.getMovieRecommendations,
    required this.getWatchListStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  }) : super(MovieDetailInitial()) {
    on<FetchMovieDetail>((event, emit) async {
      emit(MovieDetailLoading());

      final detailResult = await getMovieDetail.execute(event.id);
      final recommendationResult =
          await getMovieRecommendations.execute(event.id);
      final isAddedToWatchlist = await getWatchListStatus.execute(event.id);

      detailResult.fold(
        (failure) => emit(MovieDetailError(failure.message)),
        (movie) {
          recommendationResult.fold(
            (failure) => emit(MovieDetailError(failure.message)),
            (movies) =>
                emit(MovieDetailLoaded(movie, movies, isAddedToWatchlist)),
          );
        },
      );
    });

    on<AddToWatchlist>((event, emit) async {
      final result = await saveWatchlist.execute(event.movie);
      final detailResult = await getMovieDetail.execute(event.movie.id);
      final recommendationResult =
          await getMovieRecommendations.execute(event.movie.id);

      final recommendations = recommendationResult.fold(
        (failure) => <Movie>[],
        (movies) => movies,
      );

      final movie = detailResult.fold(
        (failure) => null,
        (movie) => movie,
      );

      if (movie != null) {
        result.fold(
          (failure) => emit(MovieDetailError(failure.message)),
          (_) => emit(MovieDetailAddRemoveSuccess(
            movie,
            recommendations,
            true,
            watchlistAddSuccessMessage,
          )),
        );
      } else {
        emit(MovieDetailError("Failed to retrieve updated movie details"));
      }
    });

    on<RemoveFromWatchlist>((event, emit) async {
      final result = await removeWatchlist.execute(event.movie);
      final detailResult = await getMovieDetail.execute(event.movie.id);
      final recommendationResult =
          await getMovieRecommendations.execute(event.movie.id);

      final recommendations = recommendationResult.fold(
        (failure) => <Movie>[],
        (movies) => movies,
      );

      final movie = detailResult.fold(
        (failure) => null,
        (movie) => movie,
      );

      if (movie != null) {
        result.fold(
          (failure) => emit(MovieDetailError(failure.message)),
          (_) => emit(MovieDetailAddRemoveSuccess(
            movie,
            recommendations,
            false,
            watchlistRemoveSuccessMessage,
          )),
        );
      } else {
        emit(MovieDetailError("Failed to retrieve updated movie details"));
      }
    });
  }
}
