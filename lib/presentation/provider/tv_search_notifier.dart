import 'package:bloc/bloc.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/search_tvs.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class TvSearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTvSearch extends TvSearchEvent {
  final String query;

  FetchTvSearch(this.query);

  @override
  List<Object> get props => [query];
}

// States
abstract class TvSearchState extends Equatable {
  @override
  List<Object> get props => [];
}

class TvSearchEmpty extends TvSearchState {}

class TvSearchLoading extends TvSearchState {}

class TvSearchLoaded extends TvSearchState {
  final List<Tv> tvs;

  TvSearchLoaded(this.tvs);

  @override
  List<Object> get props => [tvs];
}

class TvSearchError extends TvSearchState {
  final String message;

  TvSearchError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class TvSearchBloc extends Bloc<TvSearchEvent, TvSearchState> {
  final SearchTvs searchTvs;

  TvSearchBloc({required this.searchTvs}) : super(TvSearchEmpty()) {
    on<FetchTvSearch>((event, emit) async {
      emit(TvSearchLoading());
      final result = await searchTvs.execute(event.query);

      result.fold(
        (failure) => emit(TvSearchError(failure.message)),
        (tvs) => emit(TvSearchLoaded(tvs)),
      );
    });
  }
}
