import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/entities/tv_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_recommendations.dart';
import 'package:ditonton/domain/usecases/get_tv_watchlist_status.dart';
import 'package:ditonton/domain/usecases/tv_remove_watchlist.dart';
import 'package:ditonton/domain/usecases/tv_save_watchlist.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class TvDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TvDetailInitial extends TvDetailState {}

class TvDetailLoading extends TvDetailState {}

class TvDetailLoaded extends TvDetailState {
  final TvDetail tv;
  final List<Tv> recommendations;
  final bool isAddedToWatchlist;

  TvDetailLoaded(this.tv, this.recommendations, this.isAddedToWatchlist);

  @override
  List<Object?> get props => [tv, recommendations, isAddedToWatchlist];
}

class TvDetailError extends TvDetailState {
  final String message;

  TvDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class TvDetailAddRemoveSuccess extends TvDetailState {
  final TvDetail tv;
  final List<Tv> recommendations;
  final bool isAddedToWatchlist;
  final String message;

  TvDetailAddRemoveSuccess(
    this.tv,
    this.recommendations,
    this.isAddedToWatchlist,
    this.message,
  );

  @override
  List<Object?> get props => [tv, recommendations, isAddedToWatchlist, message];
}

// Events
abstract class TvDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTvDetail extends TvDetailEvent {
  final int id;

  FetchTvDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddToWatchlist extends TvDetailEvent {
  final TvDetail tv;

  AddToWatchlist(this.tv);

  @override
  List<Object?> get props => [tv];
}

class RemoveFromWatchlist extends TvDetailEvent {
  final TvDetail tv;

  RemoveFromWatchlist(this.tv);

  @override
  List<Object?> get props => [tv];
}

// Bloc
class TvDetailBloc extends Bloc<TvDetailEvent, TvDetailState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetTvDetail getTvDetail;
  final GetTvRecommendations getTvRecommendations;
  final GetTvWatchListStatus getTvWatchListStatus;
  final TvSaveWatchlist tvSaveWatchlist;
  final TvRemoveWatchlist tvRemoveWatchlist;

  TvDetailBloc({
    required this.getTvDetail,
    required this.getTvRecommendations,
    required this.getTvWatchListStatus,
    required this.tvSaveWatchlist,
    required this.tvRemoveWatchlist,
  }) : super(TvDetailInitial()) {
    on<FetchTvDetail>((event, emit) async {
      emit(TvDetailLoading());

      final detailResult = await getTvDetail.execute(event.id);
      final recommendationResult = await getTvRecommendations.execute(event.id);
      final isAddedToWatchlist = await getTvWatchListStatus.execute(event.id);

      detailResult.fold(
        (failure) => emit(TvDetailError(failure.message)),
        (tv) {
          recommendationResult.fold(
            (failure) => emit(TvDetailError(failure.message)),
            (tvs) => emit(TvDetailLoaded(tv, tvs, isAddedToWatchlist)),
          );
        },
      );
    });

    on<AddToWatchlist>((event, emit) async {
      final result = await tvSaveWatchlist.execute(event.tv);
      final detailResult = await getTvDetail.execute(event.tv.id);
      final recommendationResult =
          await getTvRecommendations.execute(event.tv.id);

      final recommendations = recommendationResult.fold(
        (failure) => <Tv>[],
        (tvs) => tvs,
      );

      final tv = detailResult.fold(
        (failure) => null,
        (tv) => tv,
      );

      if (tv != null) {
        result.fold(
          (failure) => emit(TvDetailError(failure.message)),
          (_) => emit(TvDetailAddRemoveSuccess(
            tv,
            recommendations,
            true,
            watchlistAddSuccessMessage,
          )),
        );
      } else {
        emit(TvDetailError("Failed to retrieve updated TV details"));
      }
    });

    on<RemoveFromWatchlist>((event, emit) async {
      final result = await tvRemoveWatchlist.execute(event.tv);
      final detailResult = await getTvDetail.execute(event.tv.id);
      final recommendationResult =
          await getTvRecommendations.execute(event.tv.id);

      final recommendations = recommendationResult.fold(
        (failure) => <Tv>[],
        (tvs) => tvs,
      );

      final tv = detailResult.fold(
        (failure) => null,
        (tv) => tv,
      );

      if (tv != null) {
        result.fold(
          (failure) => emit(TvDetailError(failure.message)),
          (_) => emit(TvDetailAddRemoveSuccess(
            tv,
            recommendations,
            false,
            watchlistRemoveSuccessMessage,
          )),
        );
      } else {
        emit(TvDetailError("Failed to retrieve updated TV details"));
      }
    });
  }
}
