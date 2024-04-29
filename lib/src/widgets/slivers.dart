import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lents/src/firestore/paginated_firestore_query_cubit.dart';

/// A [SliverList] that fetches data from Firestore.
///
/// This was created to provide a simple way to fetch data from Firestore and display it in a [CustomScrollView].
/// The `T` type parameter is the type of the data that will be fetched from Firestore.
///
/// It works via a [PaginatedFirestoreQueryCubit], provided via [cubit], that fetches data from Firestore and paginates it.
/// The data fetching is regulated by a [PageController], provided via [pageController]. Every time the user scrolls to the bottom of the list, the [cubit] will fetch more data.
/// This happens through a default method called [scrollListener], in case a custom one is not provided.
///
/// _P.S._: Obviously, the [PaginatedFirestoreQueryCubit] must be of type `T` to work properly.
class FirestoreSliverList<T> extends StatefulWidget {
  const FirestoreSliverList(
      {super.key,
      required this.itemBuilder,
      required this.cubit,
      this.emptyWidget,
      this.loadingWidget,
      required this.pageController,
      this.scrollListener});
  final Widget Function(BuildContext context, int index, T data) itemBuilder;
  final PaginatedFirestoreQueryCubit<T> cubit;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final PageController pageController;
  final void Function()? scrollListener;

  @override
  State<FirestoreSliverList<T>> createState() => _FirestoreSliverListState<T>();
}

class _FirestoreSliverListState<T> extends State<FirestoreSliverList<T>> {
  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(widget.scrollListener ?? scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.pageController.removeListener(widget.scrollListener ?? scrollListener);
    widget.pageController.dispose();
  }

  void scrollListener() async {
    if (widget.pageController.offset >= widget.pageController.position.maxScrollExtent - 50 &&
        widget.pageController.position.outOfRange) {
      await widget.cubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<PaginatedFirestoreQueryCubit<T>, PaginatedFirestoreQueryState<T>>(
        builder: (context, state) {
          if (state.error == null) {
            if (state.data.isNotEmpty) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => widget.itemBuilder(context, index, state.data[index]),
                  childCount: state.data.length,
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: widget.emptyWidget ?? const SizedBox(),
              );
            }
          } else {
            return SliverToBoxAdapter(
              child: widget.loadingWidget ?? const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
