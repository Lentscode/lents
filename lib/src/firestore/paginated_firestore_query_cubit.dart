import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A cubit that handles paginated queries to Firestore.
///
/// This cubit is responsible for fetching documents from Firestore, thanks to [queryBuilder],
/// and converting them to a list of items of type `T`, using [fromSnapshot].
///
/// The [docsPerPage] parameter defines how many documents will be fetched at once.
/// The [queryBuilder] function should return a [Query] object that will be used to fetch the documents.
///
/// The cubit has two main methods: [loadData] and [loadMore].
///
/// * [loadData] fetches the first batch of documents.
/// * [loadMore] fetches the next batch of documents.
///
/// **RECOMMENDATION**
///
/// This cubit is designed to be used with the `FirestoreSliverList` widget.
/// Indeed, `FirestoreSliverList` is a widget that uses this cubit to fetch documents from Firestore and
/// display them in a paginated way.
///
/// _P.S._
///
/// (We opted for a [Cubit] instead of a [Bloc] because it makes the process easier.)
class PaginatedFirestoreQueryCubit<T> extends Cubit<PaginatedFirestoreQueryState<T>> {
  /// Creates a new [PaginatedFirestoreQueryCubit] instance.
  ///
  /// It automatically emits a [PaginatedFirestoreQueryState] with an empty list of data and [hasMoreData] set to `true`.
  PaginatedFirestoreQueryCubit({
    required this.queryBuilder,
    required this.fromSnapshot,
    this.docsPerPage = 10,
  }) : super(PaginatedFirestoreQueryState<T>(data: const [], hasMoreData: true));

  /// The function that builds the query to fetch the documents.
  final Query Function() queryBuilder;

  /// The function that converts a [DocumentSnapshot] to an item of type `T`.
  final T Function(DocumentSnapshot data) fromSnapshot;

  /// The number of documents to fetch at once.
  final int docsPerPage;

  /// The last document fetched, used in [loadMore] to set the new starting point of the query.
  DocumentSnapshot? _lastDocument;

  /// Fetches the first batch of documents.
  Future<void> loadData() async {
    Query query = queryBuilder().limit(docsPerPage);

    final QuerySnapshot snapshot = await query.get();
    onDataFetched(snapshot);
  }

  /// Fetches the next batch of documents.
  Future<void> loadMore() async {
    if (_lastDocument == null) return;

    Query query = queryBuilder().startAfterDocument(_lastDocument!).limit(docsPerPage);

    final QuerySnapshot snapshot = await query.get();
    onDataFetched(snapshot);
  }

  /// Updates the state with the new data fetched.
  void onDataFetched(QuerySnapshot snapshot) {
    final items = List<T>.from(state.data)..addAll(snapshot.docs.map(fromSnapshot).toList());
    _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    bool hasMoreData = snapshot.docs.length == docsPerPage;

    emit(state.copyWith(data: items, hasMoreData: hasMoreData));
  }
}

/// The state of a [PaginatedFirestoreQueryCubit].
///
/// It contains the list of [data] fetched from Firestore, a flag, [hasMoreData], that indicates if there are more documents to fetch,
/// and an optional [error] message, in case of an error.
class PaginatedFirestoreQueryState<T> extends Equatable {
  /// The list of data fetched from Firestore.
  final List<T> data;

  /// A flag that indicates if there are more documents to fetch.
  final bool hasMoreData;

  /// An optional error message.
  final String? error;

  /// Creates a new [PaginatedFirestoreQueryState] instance.
  const PaginatedFirestoreQueryState({required this.hasMoreData, required this.data, this.error});

  @override
  List<Object?> get props => [data, hasMoreData, error];

  /// Creates a copy of this state with the given parameters.
  PaginatedFirestoreQueryState<T> copyWith({List<T>? data, bool? hasMoreData, String? error}) =>
      PaginatedFirestoreQueryState(
        data: data ?? this.data,
        hasMoreData: hasMoreData ?? this.hasMoreData,
        error: error ?? this.error,
      );
}
