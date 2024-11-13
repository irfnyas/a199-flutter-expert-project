import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tvs.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class WatchlistTvEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchWatchlistTvs extends WatchlistTvEvent {}

// States
abstract class WatchlistTvState extends Equatable {
  @override
  List<Object> get props => [];
}

class WatchlistTvEmpty extends WatchlistTvState {}

class WatchlistTvLoading extends WatchlistTvState {}

class WatchlistTvLoaded extends WatchlistTvState {
  final List<Tv> watchlistTvs;

  WatchlistTvLoaded(this.watchlistTvs);

  @override
  List<Object> get props => [watchlistTvs];
}

class WatchlistTvError extends WatchlistTvState {
  final String message;

  WatchlistTvError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class WatchlistTvBloc extends Bloc<WatchlistTvEvent, WatchlistTvState> {
  final GetWatchlistTvs getWatchlistTvs;

  WatchlistTvBloc({required this.getWatchlistTvs}) : super(WatchlistTvEmpty()) {
    on<FetchWatchlistTvs>((event, emit) async {
      emit(WatchlistTvLoading());
      final result = await getWatchlistTvs.execute();
      result.fold(
        (failure) => emit(WatchlistTvError(failure.message)),
        (tvs) => emit(WatchlistTvLoaded(tvs)),
      );
    });
  }
}
