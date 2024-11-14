import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/presentation/pages/top_rated_tvs_page.dart';
import 'package:ditonton/presentation/provider/top_rated_tvs_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

class FakeTopRatedTvsBloc extends MockBloc<TopRatedTvsEvent, TopRatedTvsState>
    implements TopRatedTvsBloc {}

@GenerateMocks([TopRatedTvsBloc])
void main() {
  late FakeTopRatedTvsBloc fakeBloc;

  setUp(() {
    fakeBloc = FakeTopRatedTvsBloc();
  });

  Widget _makeTestableWidget(Widget body) {
    return BlocProvider<TopRatedTvsBloc>.value(
      value: fakeBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    whenListen(
        fakeBloc, Stream<TopRatedTvsState>.fromIterable([TopRatedTvsLoading()]),
        initialState: TopRatedTvsEmpty());

    final progressFinder = find.byType(CircularProgressIndicator);
    final centerFinder = find.byType(Center);

    await tester.pumpWidget(_makeTestableWidget(TopRatedTvsPage()));
    await tester.pump();

    expect(centerFinder, findsOneWidget);
    expect(progressFinder, findsOneWidget);
  });

  testWidgets('Page should display when data is loaded',
      (WidgetTester tester) async {
    whenListen(fakeBloc,
        Stream<TopRatedTvsState>.fromIterable([TopRatedTvsLoaded(<Tv>[])]),
        initialState: TopRatedTvsEmpty());

    final listViewFinder = find.byType(ListView);

    await tester.pumpWidget(_makeTestableWidget(TopRatedTvsPage()));
    await tester.pump();

    expect(listViewFinder, findsOneWidget);
  });

  testWidgets('Page should display text with message when Error',
      (WidgetTester tester) async {
    whenListen(
        fakeBloc,
        Stream<TopRatedTvsState>.fromIterable(
            [TopRatedTvsError('Error message')]),
        initialState: TopRatedTvsEmpty());

    final textFinder = find.byKey(Key('error_message'));

    await tester.pumpWidget(_makeTestableWidget(TopRatedTvsPage()));
    await tester.pump();

    expect(textFinder, findsOneWidget);
  });
}
