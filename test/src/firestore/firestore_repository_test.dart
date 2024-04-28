import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lents/src/firestore/firestore_repository.dart';

import '../../test_utils.dart';

void main() {
  late FirestoreRepository<Person> firestoreRepository;
  late FakeFirebaseFirestore instance;

  setUp(() async {
    instance = FakeFirebaseFirestore();
    firestoreRepository = FirestoreRepository<Person>(
      'people',
      (snapshot) => Person(
        first: snapshot['first'],
        last: snapshot['last'],
      ),
      firestore: instance,
    );

    await instance.collection('people').doc('person1').set({
      'first': 'Thomas',
      'last': 'Mack',
      'friends': 3,
    });
    await instance.collection('people').doc('person2').set({
      'first': 'Donald',
      'last': 'Ball',
      'friends': 5,
    });
  });

  test('return post from ref', () async {
    final post = await firestoreRepository.getDocumentByReference(
      instance.collection('people').doc('person1'),
    );

    expect(post, isA<Person>());
    expect(post.first, 'Thomas');
    expect(post.last, 'Mack');
  });

  test('return list of people', () async {
    final references = [
      instance.collection('people').doc('person1'),
      instance.collection('people').doc('person2'),
    ];

    final people = await firestoreRepository.getDocumentsByReferences(references);

    expect(people, isA<List<Person>>());
    expect(people[0].first, 'Thomas');
    expect(people[1].last, 'Ball');
  });

  test('return person by id', () async {
    final person = await firestoreRepository.getDocumentById('person1');

    expect(person, isA<Person>());
    expect(person.first, 'Thomas');
    expect(person.last, 'Mack');
  });

  group('getDocumentsByFilters', () {
    test('return people with more than 5 friends', () async {
      final people = await firestoreRepository.getDocumentsByFilters([
        FirestoreFilter('friends', FirestoreFilterType.isGreaterThanOrEqualTo, 5),
      ]);

      expect(people, isA<List<Person>>());
      expect(people.length, 1);
      expect(people[0].first, 'Donald');
    });

    test('return people with less than 2 friends', () async {
      final people = await firestoreRepository.getDocumentsByFilters([
        FirestoreFilter('friends', FirestoreFilterType.isLessThan, 2),
      ]);

      expect(people, isA<List<Person>>());
      expect(people.length, 0);
    });

    test('return people with first = Thomas', () async {
      final people = await firestoreRepository.getDocumentsByFilters([
        FirestoreFilter('first', FirestoreFilterType.isEqualTo, 'Thomas'),
      ]);

      expect(people, isA<List<Person>>());
      expect(people.length, 1);
      expect(people[0].last, 'Mack');
    });
  });
}
