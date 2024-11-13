import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_popular_tvs.dart';
import 'package:equatable/equatable.dart';

// Define Events
abstract class PopularTvsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchPopularTvsEvent extends PopularTvsEvent {}

// Define States
abstract class PopularTvsState extends Equatable {
  @override
  List<Object> get props => [];
}

class PopularTvsEmpty extends PopularTvsState {}

class PopularTvsLoading extends PopularTvsState {}

class PopularTvsLoaded extends PopularTvsState {
  final List<Tv> tvs;

  PopularTvsLoaded(this.tvs);

  @override
  List<Object> get props => [tvs];
}

class PopularTvsError extends PopularTvsState {
  final String message;

  PopularTvsError(this.message);

  @override
  List<Object> get props => [message];
}

// Define Bloc
class PopularTvsBloc extends Bloc<PopularTvsEvent, PopularTvsState> {
  final GetPopularTvs getPopularTvs;

  PopularTvsBloc(this.getPopularTvs) : super(PopularTvsEmpty()) {
    on<FetchPopularTvsEvent>((event, emit) async {
      emit(PopularTvsLoading());
      final result = await getPopularTvs.execute();

      result.fold(
        (failure) => emit(PopularTvsError(failure.message)),
        (tvs) => emit(PopularTvsLoaded(tvs)),
      );
    });
  }
}
