import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tvs.dart';
import 'package:equatable/equatable.dart';

// Define Events
abstract class TopRatedTvsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTopRatedTvsEvent extends TopRatedTvsEvent {}

// Define States
abstract class TopRatedTvsState extends Equatable {
  @override
  List<Object> get props => [];
}

class TopRatedTvsEmpty extends TopRatedTvsState {}

class TopRatedTvsLoading extends TopRatedTvsState {}

class TopRatedTvsLoaded extends TopRatedTvsState {
  final List<Tv> tvs;

  TopRatedTvsLoaded(this.tvs);

  @override
  List<Object> get props => [tvs];
}

class TopRatedTvsError extends TopRatedTvsState {
  final String message;

  TopRatedTvsError(this.message);

  @override
  List<Object> get props => [message];
}

// Define Bloc
class TopRatedTvsBloc extends Bloc<TopRatedTvsEvent, TopRatedTvsState> {
  final GetTopRatedTvs getTopRatedTvs;

  TopRatedTvsBloc({required this.getTopRatedTvs}) : super(TopRatedTvsEmpty()) {
    on<FetchTopRatedTvsEvent>((event, emit) async {
      emit(TopRatedTvsLoading());
      final result = await getTopRatedTvs.execute();

      result.fold(
        (failure) => emit(TopRatedTvsError(failure.message)),
        (tvs) => emit(TopRatedTvsLoaded(tvs)),
      );
    });
  }
}
