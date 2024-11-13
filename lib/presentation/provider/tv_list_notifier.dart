import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tvs.dart';
import 'package:ditonton/domain/usecases/get_popular_tvs.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tvs.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class TvListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchNowPlayingTvs extends TvListEvent {}

class FetchPopularTvs extends TvListEvent {}

class FetchTopRatedTvs extends TvListEvent {}

// States
abstract class TvListState extends Equatable {
  @override
  List<Object> get props => [];
}

class TvListEmpty extends TvListState {}

class TvListLoading extends TvListState {}

class TvListLoaded extends TvListState {
  final List<Tv> nowPlayingTvs;
  final List<Tv> popularTvs;
  final List<Tv> topRatedTvs;

  TvListLoaded({
    this.nowPlayingTvs = const [],
    this.popularTvs = const [],
    this.topRatedTvs = const [],
  });

  @override
  List<Object> get props => [nowPlayingTvs, popularTvs, topRatedTvs];
}

class TvListError extends TvListState {
  final String message;

  TvListError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class TvListBloc extends Bloc<TvListEvent, TvListState> {
  final GetNowPlayingTvs getNowPlayingTvs;
  final GetPopularTvs getPopularTvs;
  final GetTopRatedTvs getTopRatedTvs;

  List<Tv> nowPlayingTvs = [];
  List<Tv> popularTvs = [];
  List<Tv> topRatedTvs = [];

  TvListBloc({
    required this.getNowPlayingTvs,
    required this.getPopularTvs,
    required this.getTopRatedTvs,
  }) : super(TvListEmpty()) {
    on<FetchNowPlayingTvs>((event, emit) async {
      emit(TvListLoading());
      final result = await getNowPlayingTvs.execute();
      result.fold(
        (failure) => emit(TvListError(failure.message)),
        (tvs) {
          nowPlayingTvs = tvs;
          emit(TvListLoaded(
            nowPlayingTvs: nowPlayingTvs,
            popularTvs: popularTvs,
            topRatedTvs: topRatedTvs,
          ));
        },
      );
    });

    on<FetchPopularTvs>((event, emit) async {
      emit(TvListLoading());
      final result = await getPopularTvs.execute();
      result.fold(
        (failure) => emit(TvListError(failure.message)),
        (tvs) {
          popularTvs = tvs;
          emit(TvListLoaded(
            nowPlayingTvs: nowPlayingTvs,
            popularTvs: popularTvs,
            topRatedTvs: topRatedTvs,
          ));
        },
      );
    });

    on<FetchTopRatedTvs>((event, emit) async {
      emit(TvListLoading());
      final result = await getTopRatedTvs.execute();
      result.fold(
        (failure) => emit(TvListError(failure.message)),
        (tvs) {
          topRatedTvs = tvs;
          emit(TvListLoaded(
            nowPlayingTvs: nowPlayingTvs,
            popularTvs: popularTvs,
            topRatedTvs: topRatedTvs,
          ));
        },
      );
    });
  }
}
