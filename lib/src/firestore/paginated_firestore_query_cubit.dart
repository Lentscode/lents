import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PaginatedFirestoreQueryCubit<T> extends Cubit<PaginatedFirestoreQueryState<T>> {
  PaginatedFirestoreQueryCubit({
    required this.queryBuilder,
    required this.fromSnapshot,
    this.docsPerPage = 10,
  }) : super(PaginatedFirestoreQueryState<T>(data: const [], hasMoreData: true));

  final Query Function() queryBuilder;
  final T Function(DocumentSnapshot data) fromSnapshot;
  final int docsPerPage;

  DocumentSnapshot? _lastDocument;

  Future<void> loadData() async {
    Query query = queryBuilder().limit(docsPerPage);

    final QuerySnapshot snapshot = await query.get();
    onDataFetched(snapshot);
  }

  Future<void> loadMore() async {
    if (_lastDocument == null) return;

    Query query = queryBuilder().startAfterDocument(_lastDocument!).limit(docsPerPage);

    final QuerySnapshot snapshot = await query.get();
    onDataFetched(snapshot);
  }

  void onDataFetched(QuerySnapshot snapshot) {
    final items = List<T>.from(state.data)..addAll(snapshot.docs.map(fromSnapshot).toList());
    _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    bool hasMoreData = snapshot.docs.length == docsPerPage;

    emit(state.copyWith(data: items, hasMoreData: hasMoreData));
  }
}

class PaginatedFirestoreQueryState<T> extends Equatable {
  final List<T> data;
  final bool hasMoreData;
  final String? error;

  const PaginatedFirestoreQueryState({required this.hasMoreData, required this.data, this.error});

  @override
  List<Object?> get props => [data, hasMoreData, error];

  PaginatedFirestoreQueryState<T> copyWith({List<T>? data, bool? hasMoreData, String? error}) =>
      PaginatedFirestoreQueryState(
        data: data ?? this.data,
        hasMoreData: hasMoreData ?? this.hasMoreData,
        error: error ?? this.error,
      );
}
