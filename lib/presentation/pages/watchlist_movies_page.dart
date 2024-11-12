import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/provider/watchlist_movie_notifier.dart';
import 'package:ditonton/presentation/provider/watchlist_tv_notifier.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    Future.microtask(() {
      Provider.of<WatchlistMovieNotifier>(context, listen: false)
          .fetchWatchlistMovies();
      Provider.of<WatchlistTvNotifier>(context, listen: false)
          .fetchWatchlistTvs();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void didPopNext() {
    Provider.of<WatchlistMovieNotifier>(context, listen: false)
        .fetchWatchlistMovies();
    Provider.of<WatchlistTvNotifier>(context, listen: false)
        .fetchWatchlistTvs();
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
                  Consumer<WatchlistTvNotifier>(builder: (_, __, ___) {
                    return Tab(
                      text:
                          'Tv Series (${Provider.of<WatchlistTvNotifier>(context, listen: false).watchlistTvs.length})',
                    );
                  }),
                  Consumer<WatchlistMovieNotifier>(builder: (_, __, ___) {
                    return Tab(
                      text:
                          'Movies (${Provider.of<WatchlistMovieNotifier>(context, listen: false).watchlistMovies.length})',
                    );
                  }),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Consumer<WatchlistTvNotifier>(
                      builder: (context, data, child) {
                        if (data.watchlistState == RequestState.Loading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (data.watchlistState == RequestState.Loaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemBuilder: (context, index) {
                              final tv = data.watchlistTvs[index];
                              return TvCard(tv);
                            },
                            itemCount: data.watchlistTvs.length,
                          );
                        } else {
                          return Center(
                            key: Key('error_message'),
                            child: Text(data.message),
                          );
                        }
                      },
                    ),
                    Consumer<WatchlistMovieNotifier>(
                      builder: (context, data, child) {
                        if (data.watchlistState == RequestState.Loading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (data.watchlistState == RequestState.Loaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemBuilder: (context, index) {
                              final movie = data.watchlistMovies[index];
                              return MovieCard(movie);
                            },
                            itemCount: data.watchlistMovies.length,
                          );
                        } else {
                          return Center(
                            key: Key('error_message'),
                            child: Text(data.message),
                          );
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
