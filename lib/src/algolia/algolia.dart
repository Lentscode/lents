import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

/// Class that simplifies the usage of Algolia in Flutter applications. It is built on ```algolia_flutter_helper``` package.
///
/// Providing a type ```T```, it fetches data from Algolia and converts it to objects of type ```T```.
/// Suppose you have a class named ```Person```:
///
/// ``` dart
/// Class Person {
///   Person({required this.name, required this.age});
///
///   final String name;
///   final int age;
///
///   Person.fromAlgolia(Hit hit)
///     : first = hit['first'] as String,
///       last = hit['last'] as String,
///       friends = hit['friends'] as int;
/// }
/// ```
///
/// You can use the ```Algolia``` class to fetch data from Algolia and convert it to ```Person``` objects.
/// ```dart
///
/// final algolia = Algolia<Person>(
///   indexName: 'people',
///   applicationId: /* your app id*/,
///   apiKey: /* your api key */,
///   fromJson: (data) => Person.fromAlgolia(data),
/// );
///
/// ```
///
/// To access the data, you can use the ```data``` property. This gives you a Stream of List of ```T```.
/// It is updated depending on the state of the ```Algolia``` object.
///
/// ```dart
///
/// final people = algolia.data;
///
/// ```
class Algolia<T> {
  /// Creates a new instance of [Algolia].
  /// - [indexName] is the name of the index in Algolia.
  /// - [applicationId] is the application id of your Algolia account.
  /// - [apiKey] is the api key of your Algolia account.
  /// - [fromJson] is a function that converts a [Hit] to an object of type ```T```.
  Algolia.index(
      {required String indexName, required String applicationId, required String apiKey, required this.fromJson})
      : searcher = HitsSearcher(indexName: indexName, applicationID: applicationId, apiKey: apiKey)
          ..applyState((state) => state.copyWith(page: 1));

  /// The instance of [HitsSearcher] used in the class.
  final HitsSearcher searcher;

  /// A function that converts a [Hit] to an object of type ```T```.
  final T Function(Hit data) fromJson;

  /// Method that retrieves the documents matching the [query].
  void query(String query) => searcher.query(query);

  /// Method that applies a [state] to the [searcher].
  /// It is used to update some parameters of the search, like the [query], [page], etc.
  void applyState(SearchState Function(SearchState) state) => searcher.applyState(state);

  /// Stream of List of ```T```.
  /// It returns the data fetched from Algolia and converted to objects of type ```T```.
  /// 
  /// It is updated depending on the state of the ```Algolia``` object.
  Stream<List<T>> get data => searcher.responses.map((event) => event.hits.map((e) => fromJson(e)).toList());

  /// Method to call when the fetching process is no longer needed.
  void dispose() => searcher.dispose();

  /// The current page of the search.
  int page = 1;

  /// Method that fetches the next page of the search.
  void nextPage() {
    page++;
    searcher.applyState((state) => state.copyWith(page: page));
  }

  /// The current state of the search.
  SearchState get state => searcher.snapshot();
}
