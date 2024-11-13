import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/provider/watchlist_movie_notifier.dart';
import 'package:ditonton/presentation/provider/watchlist_tv_notifier.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchlistMoviesPage extends StatefulWidget {
  static const ROUTE_NAME = '/watchlist-movie';

  @override
  _WatchlistMoviesPageState createState() => _WatchlistMoviesPageState();
}

class _WatchlistMoviesPageState extends State<WatchlistMoviesPage>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<WatchlistMovieBloc>().add(FetchWatchlistMovies());
    context.read<WatchlistTvBloc>().add(FetchWatchlistTvs());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void didPopNext() {
    context.read<WatchlistMovieBloc>().add(FetchWatchlistMovies());
    context.read<WatchlistTvBloc>().add(FetchWatchlistTvs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TabBar(
                tabs: [
                  BlocBuilder<WatchlistTvBloc, WatchlistTvState>(
                    builder: (context, state) {
                      final count = (state is WatchlistTvLoaded)
                          ? state.watchlistTvs.length
                          : 0;
                      return Tab(text: 'TV Series ($count)');
                    },
                  ),
                  BlocBuilder<WatchlistMovieBloc, WatchlistMovieState>(
                    builder: (context, state) {
                      final count = (state is WatchlistMovieLoaded)
                          ? state.watchlistMovies.length
                          : 0;
                      return Tab(text: 'Movies ($count)');
                    },
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    BlocBuilder<WatchlistTvBloc, WatchlistTvState>(
                      builder: (context, state) {
                        if (state is WatchlistTvLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is WatchlistTvLoaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemBuilder: (context, index) {
                              final tv = state.watchlistTvs[index];
                              return TvCard(tv);
                            },
                            itemCount: state.watchlistTvs.length,
                          );
                        } else if (state is WatchlistTvError) {
                          return Center(
                            key: Key('error_message'),
                            child: Text(state.message),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    BlocBuilder<WatchlistMovieBloc, WatchlistMovieState>(
                      builder: (context, state) {
                        if (state is WatchlistMovieLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is WatchlistMovieLoaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemBuilder: (context, index) {
                              final movie = state.watchlistMovies[index];
                              return MovieCard(movie);
                            },
                            itemCount: state.watchlistMovies.length,
                          );
                        } else if (state is WatchlistMovieError) {
                          return Center(
                            key: Key('error_message'),
                            child: Text(state.message),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}
