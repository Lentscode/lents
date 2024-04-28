import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lents/lents.dart';

import '../../test_utils.dart';

void main() {
  late FakeFirebaseFirestore instance;

  setUpAll(() {
    instance = FakeFirebaseFirestore();

    instance.collection('people').doc('person1').set({
      'first': 'Thomas',
      'last': 'Mack',
      'friends': 3,
    });
    instance.collection('people').doc('person2').set({
      'first': 'Donald',
      'last': 'Ball',
      'friends': 5,
    });
    instance.collection('people').doc('person3').set({
      'first': 'John',
      'last': 'Doe',
      'friends': 2,
    });
  });

  group('PaginatedFirestoreQueryCubit', () {
    final defaultCubit = PaginatedFirestoreQueryCubit<Person>(
      queryBuilder: () => instance.collection('people'),
      fromSnapshot: (snapshot) => Person(
        first: snapshot['first'],
        last: snapshot['last'],
        friends: snapshot['friends'],
      ),
    );

    final cubit1 = PaginatedFirestoreQueryCubit(
        queryBuilder: () => instance.collection('people'),
        fromSnapshot: (snapshot) => Person(
              first: snapshot['first'],
              last: snapshot['last'],
              friends: snapshot['friends'],
            ),
        docsPerPage: 2);

    final cubit2 = PaginatedFirestoreQueryCubit(
      queryBuilder: () => instance.collection('people').orderBy('friends', descending: true),
      fromSnapshot: (snapshot) => Person(
        first: snapshot['first'],
        last: snapshot['last'],
        friends: snapshot['friends'],
      ),
    );

    blocTest(
      'check initial state on creation',
      build: () => defaultCubit,
      act: (bloc) => null,
      expect: () => [],
    );

    blocTest(
      'check state after calling loadData',
      build: () => defaultCubit,
      act: (bloc) => bloc.loadData(),
      expect: () => [isA<PaginatedFirestoreQueryState>()],
      verify: (bloc) {
        return bloc.state.data.length == 3 &&
            bloc.state.hasMoreData == false &&
            bloc.state.data.map((e) => e.first).toList() == ['Thomas', 'Donald', 'John'];
      },
    );

    blocTest(
      'check state after calling loadData and docsPerPage is 2',
      build: () => cubit1,
      act: (bloc) => bloc.loadData(),
      expect: () => [isA<PaginatedFirestoreQueryState>()],
      verify: (bloc) {
        return bloc.state.data.length == 2 &&
            bloc.state.hasMoreData == true &&
            bloc.state.data.map((e) => e.first).toList() == ['Thomas', 'Donald'];
      },
    );

    blocTest(
      'check state after calling loadMore and docsPerPage is 2',
      build: () => cubit1,
      act: (bloc) async {
        await bloc.loadData();
        await bloc.loadMore();
      },
      expect: () => [isA<PaginatedFirestoreQueryState>(), isA<PaginatedFirestoreQueryState>()],
      verify: (bloc) {
        return bloc.state.data.length == 1 &&
            bloc.state.hasMoreData == false &&
            bloc.state.data.map((e) => e.first).toList() == ['John'];
      },
    );

    blocTest(
      'check state after calling loadData and giving orderBy',
      build: () => cubit2,
      act: (bloc) => bloc.loadData(),
      expect: () => [isA<PaginatedFirestoreQueryState>()],
      verify: (bloc) {
        return bloc.state.data.length == 3 &&
            bloc.state.hasMoreData == false &&
            bloc.state.data.map((e) => e.first).toList() == ['Donald', 'Thomas', 'John'];
      },
    );
  });
}
