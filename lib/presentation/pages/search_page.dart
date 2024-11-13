import 'package:ditonton/common/constants.dart';
import 'package:ditonton/presentation/provider/movie_search_notifier.dart';
import 'package:ditonton/presentation/provider/tv_search_notifier.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatelessWidget {
  static const ROUTE_NAME = '/search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onSubmitted: (query) {
                  context.read<MovieSearchBloc>().add(FetchMovieSearch(query));
                  context.read<TvSearchBloc>().add(FetchTvSearch(query));
                },
                decoration: InputDecoration(
                  hintText: 'Search title',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
              ),
              SizedBox(height: 16),
              Text(
                'Search Result',
                style: kHeading6,
              ),
              TabBar(
                tabs: [
                  BlocBuilder<TvSearchBloc, TvSearchState>(
                    builder: (context, state) {
                      final count =
                          (state is TvSearchLoaded) ? state.tvs.length : 0;
                      return Tab(text: 'Tv Series ($count)');
                    },
                  ),
                  BlocBuilder<MovieSearchBloc, MovieSearchState>(
                    builder: (context, state) {
                      final count = (state is MovieSearchLoaded)
                          ? state.movies.length
                          : 0;
                      return Tab(text: 'Movies ($count)');
                    },
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    BlocBuilder<TvSearchBloc, TvSearchState>(
                      builder: (context, state) {
                        if (state is TvSearchLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is TvSearchLoaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final tv = state.tvs[index];
                              return TvCard(tv);
                            },
                            itemCount: state.tvs.length,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    BlocBuilder<MovieSearchBloc, MovieSearchState>(
                      builder: (context, state) {
                        if (state is MovieSearchLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is MovieSearchLoaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final movie = state.movies[index];
                              return MovieCard(movie);
                            },
                            itemCount: state.movies.length,
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
}
