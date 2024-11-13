import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_now_playing_tvs.dart';
import 'package:equatable/equatable.dart';

// Define Events
abstract class NowPlayingTvsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchNowPlayingTvsEvent extends NowPlayingTvsEvent {}

// Define States
abstract class NowPlayingTvsState extends Equatable {
  @override
  List<Object> get props => [];
}

class NowPlayingTvsEmpty extends NowPlayingTvsState {}

class NowPlayingTvsLoading extends NowPlayingTvsState {}

class NowPlayingTvsLoaded extends NowPlayingTvsState {
  final List<Tv> tvs;

  NowPlayingTvsLoaded(this.tvs);

  @override
  List<Object> get props => [tvs];
}

class NowPlayingTvsError extends NowPlayingTvsState {
  final String message;

  NowPlayingTvsError(this.message);

  @override
  List<Object> get props => [message];
}

// Define Bloc
class NowPlayingTvsBloc extends Bloc<NowPlayingTvsEvent, NowPlayingTvsState> {
  final GetNowPlayingTvs getNowPlayingTvs;

  NowPlayingTvsBloc(this.getNowPlayingTvs) : super(NowPlayingTvsEmpty()) {
    on<FetchNowPlayingTvsEvent>((event, emit) async {
      emit(NowPlayingTvsLoading());
      final result = await getNowPlayingTvs.execute();

      result.fold(
        (failure) => emit(NowPlayingTvsError(failure.message)),
        (tvs) => emit(NowPlayingTvsLoaded(tvs)),
      );
    });
  }
}
