import 'package:cloud_firestore/cloud_firestore.dart';

/// Class that provides a set of methods to fetch data from Firestore, and convert it to objects of type T.
///
/// For instance, suppose you have a Firestore collection called "people", and you want to fetch a list of people from it.
/// The Dart model class for a person could be:
///
/// ``` dart
///
/// Class Person {
///   Person({required this.name, required this.age});
///
///   final String name;
///   final int age;
/// }
/// ```
///
/// If you have an id of a document, you can use the ```getDocumentById()``` method.
///
/// ```dart
///
/// final repo = await FirestoreRepository<Person>(
///   'people',
///   (snap) => Person(
///     name: snap['name'],
///     age: snap['age'],
///   ),
/// );
///
/// final user = await repo.getDocumentById(id);
/// ```
///
/// **RECOMMENDATION**
///
/// We recommend to have a constructor in your model class to convert a ```DocumentSnapshot``` to an instance of your class.
///
/// ```dart
/// class Person{
///   Person({required this.name, required this.age});
///
///   final String name;
///   final int age;
///
///   // To pass in FirestoreRepository
///   Person.fromSnapshot(DocumentSnapshot snap) :
///       name = snap['name'],
///       age = snap['age'];
/// }
/// ```
class FirestoreRepository<T> {
  /// Creates a new instance of [FirestoreRepository].
  ///
  /// With this you can fetch data from Firestore in the collection "[collectionName]" and convert it to objects of type T via [fromSnapshot].
  /// [firestore] is optional (used for testing purpose), and if not provided, it will use the default instance of Firestore .
  FirestoreRepository(this.collectionName, this.fromSnapshot, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// The instance of FirebaseFirestore, used in methods.
  final FirebaseFirestore _firestore;

  /// The name of the collection in Firestore in which the documents to fetch are stored.
  final String collectionName;

  /// A function that converts a [DocumentSnapshot] to an object of type T.
  final T Function(DocumentSnapshot snap) fromSnapshot;

  /// Fetches a document from Firestore by its reference.
  ///
  /// ```dart
  /// final person = await repo.getDocumentByReference(reference);
  /// ```
  Future<T> getDocumentByReference(DocumentReference reference) async {
    final snapshot = await reference.get();
    return fromSnapshot(snapshot);
  }

  /// Fetches a list of documents from Firestore by their references.
  ///
  /// ```dart
  /// final people = await repo.getDocumentsByReferences(references);
  /// ```
  Future<List<T>> getDocumentsByReferences(List<DocumentReference> references) async {
    final snapshots = await Future.wait(references.map((ref) => ref.get()));
    return snapshots.map((snapshot) => fromSnapshot(snapshot)).toList();
  }

  /// Fetches a document from Firestore by its id.
  ///
  /// ```dart
  /// final person = await repo.getDocumentById(id);
  /// ```
  Future<T> getDocumentById(String id) async {
    final snapshot = await _firestore.collection(collectionName).doc(id).get();
    return fromSnapshot(snapshot);
  }

  /// Fetches a list of documents from Firestore given certain filters.
  ///
  /// These filters are in form of [FirestoreFilter] objects.
  /// In the example below, we fetch all documents where the field "age" is greater than 18.
  ///
  /// ```dart
  /// final adults = await repo.getDocumentsByFilters([FirestoreFilter('age', FirestoreFilterType.isGreaterThan, 18)]);
  /// ```
  ///
  /// You can also pass a field to order the results by, and a boolean to indicate if the order is descending.
  ///
  /// ```dart
  ///
  /// final adultsOrdered = await repo.getDocumentsByFilters(
  ///     [FirestoreFilter('age', FirestoreFilterType.isGreaterThan, 18)],
  ///     field: 'age',
  ///     descending: true);
  /// ```
  Future<List<T>> getDocumentsByFilters(List<FirestoreFilter> filters, {Object? field, bool descending = false}) async {
    Query query = _firestore.collection(collectionName);
    for (final filter in filters) {
      switch (filter.type) {
        case FirestoreFilterType.isEqualTo:
          query = query.where(filter.field, isEqualTo: filter.value);
          break;
        case FirestoreFilterType.isNotEqualTo:
          query = query.where(filter.field, isNotEqualTo: filter.value);
          break;
        case FirestoreFilterType.isLessThan:
          query = query.where(filter.field, isLessThan: filter.value);
          break;
        case FirestoreFilterType.isLessThanOrEqualTo:
          query = query.where(filter.field, isLessThanOrEqualTo: filter.value);
          break;
        case FirestoreFilterType.isGreaterThan:
          query = query.where(filter.field, isGreaterThan: filter.value);
          break;
        case FirestoreFilterType.isGreaterThanOrEqualTo:
          query = query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
          break;
        case FirestoreFilterType.arrayContains:
          query = query.where(filter.field, arrayContains: filter.value);
          break;
        case FirestoreFilterType.arrayContainsAny:
          query = query.where(filter.field, arrayContainsAny: filter.value);
          break;
        case FirestoreFilterType.whereIn:
          query = query.where(filter.field, whereIn: filter.value as List);
          break;
        case FirestoreFilterType.whereNotIn:
          query = query.where(filter.field, whereNotIn: filter.value as List);
          break;
        case FirestoreFilterType.isNull:
          query = query.where(filter.field, isNull: true);
          break;
      }
    }

    if (field != null) {
      query = query.orderBy(field, descending: descending);
    }

    final snapshots = await query.get();
    return snapshots.docs.map((doc) => fromSnapshot(doc)).toList();
  }

  /// Method that returns a stream of a document from Firestore by its reference.
  ///
  /// It means that every time the document changes, the stream will emit a new ```T``` object
  /// representing the document.
  Stream<T> streamDocumentByReference(DocumentReference reference) {
    return reference.snapshots().map((snapshot) => fromSnapshot(snapshot));
  }

  /// Method that returns a stream of a list of documents from Firestore that match certain filters.
  ///
  /// A new ```List<T>``` will be emitted in this three cases:
  /// - When a document is added to the collection that matches the filters.
  /// - When a document is removed from the collection that matches the filters.
  /// - When a document is updated in the collection that matches or not matches the filters.
  Stream<List<T>> streamDocumentsByFilters(List<FirestoreFilter> filters) {
    Query query = _firestore.collection(collectionName);
    for (final filter in filters) {
      switch (filter.type) {
        case FirestoreFilterType.isEqualTo:
          query = query.where(filter.field, isEqualTo: filter.value);
          break;
        case FirestoreFilterType.isNotEqualTo:
          query = query.where(filter.field, isNotEqualTo: filter.value);
          break;
        case FirestoreFilterType.isLessThan:
          query = query.where(filter.field, isLessThan: filter.value);
          break;
        case FirestoreFilterType.isLessThanOrEqualTo:
          query = query.where(filter.field, isLessThanOrEqualTo: filter.value);
          break;
        case FirestoreFilterType.isGreaterThan:
          query = query.where(filter.field, isGreaterThan: filter.value);
          break;
        case FirestoreFilterType.isGreaterThanOrEqualTo:
          query = query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
          break;
        case FirestoreFilterType.arrayContains:
          query = query.where(filter.field, arrayContains: filter.value);
          break;
        case FirestoreFilterType.arrayContainsAny:
          query = query.where(filter.field, arrayContainsAny: filter.value);
          break;
        case FirestoreFilterType.whereIn:
          query = query.where(filter.field, whereIn: filter.value as List);
          break;
        case FirestoreFilterType.whereNotIn:
          query = query.where(filter.field, whereNotIn: filter.value as List);
          break;
        case FirestoreFilterType.isNull:
          query = query.where(filter.field, isNull: true);
          break;
      }
    }
    return query.snapshots().map((snapshots) => snapshots.docs.map((doc) => fromSnapshot(doc)).toList());
  }
}

/// Class that represents a filter to be used in Firestore queries.
///
/// - [field] is the field in the document to filter by.
/// - [type] is the type of filter to apply.
/// - [value] is the value to compare with the field.
class FirestoreFilter {
  /// Creates a new filter for a query.
  FirestoreFilter(this.field, this.type, this.value);

  /// The field in the document to filter by.
  final String field;

  /// The type of filter to apply.
  final FirestoreFilterType type;

  /// The value to compare with the field.
  final dynamic value;
}

/// Enum that represents the type of filter to apply in Firestore queries.
enum FirestoreFilterType {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}
