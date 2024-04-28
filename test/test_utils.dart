import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class Person {
  final String first;
  final String last;
  final int friends;

  Person({required this.first, required this.last, this.friends = 0});

  Person.fromAlgolia(Hit hit)
      : first = hit['first'] as String,
        last = hit['last'] as String,
        friends = hit['friends'] as int;
}

class FakeFirestoreSetter {
  static void setFakeFirestore(FakeFirebaseFirestore instance) {
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
  }
}

class AlgoliaData {
  static final Stream<List<Map<String, dynamic>>> hits = Stream.fromIterable([
    [
      {
        'first': 'Thomas',
        'last': 'Mack',
        'friends': 3,
      },
      {
        'first': 'Donald',
        'last': 'Ball',
        'friends': 5,
      },
      {
        'first': 'John',
        'last': 'Doe',
        'friends': 2,
      },
    ]
  ]);
}
