import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lents/lents.dart';

import '../../test_utils.dart';

void main() {
  late FakeFirebaseFirestore instance;
  late PaginatedFirestoreQueryCubit<Person> cubit;

  setUp(() {
    instance = FakeFirebaseFirestore();
    cubit = PaginatedFirestoreQueryCubit<Person>(
      queryBuilder: () => instance.collection('people'),
      fromSnapshot: (snapshot) => Person(
        first: snapshot['first'],
        last: snapshot['last'],
        friends: snapshot['friends'],
      ),
      docsPerPage: 2,
    );
    FakeFirestoreSetter.setFakeFirestore(instance);
  });

  group('FirestoreSliverList', () {
    final PageController pageController = PageController();
    testWidgets('testing scrolling and data fetching', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: pageController,
              slivers: [
                FirestoreSliverList<Person>(
                  pageController: pageController,
                  cubit: cubit,
                  itemBuilder: (context, index, person) {
                    return SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Text(
                        person.first,
                        key: ValueKey(person.first),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      cubit.loadData();

      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsNWidgets(2));

      pageController.jumpTo(200);

      await tester.pump(const Duration(seconds: 1));

      debugPrint(cubit.state.data.map((e) => e.first).toString());

      expect(find.byKey(const ValueKey('John')), findsNWidgets(1));

      expect(find.byType(Text), findsNWidgets(3));
    });
  });
}
