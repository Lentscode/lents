import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lents/lents.dart';

import '../../test_utils.dart';

void main() {
  late Algolia<Person> algolia;

  setUp(() {
    algolia = Algolia.index(
      apiKey: 'apiKey',
      indexName: 'people',
      applicationId: 'applicationId',
      fromJson: (data) => Person(
        first: data['first'],
        last: data['last'],
        friends: data['friends'],
      ),
    );
  });

  group('Algolia', () {
    test('check initial state', () {
      final searchState = algolia.searcher.snapshot();
      expect(searchState.indexName, 'people');
    });

    test('check query()', () {
      algolia.query('query');
      final searchState = algolia.searcher.snapshot();
      expect(searchState.query, 'query');
    });

    test('check applyState()', () {
      const newState = SearchState(query: 'query', indexName: 'people', page: 1);
      algolia.applyState((state) => newState);
      final searchState = algolia.searcher.snapshot();
      expect(searchState, equals(newState));
    });

    test('check nextPage()', () {
      expect(algolia.page, 1);
      algolia.nextPage();
      final searchState = algolia.searcher.snapshot();
      expect(searchState.page, 2);
    });
  });
}
