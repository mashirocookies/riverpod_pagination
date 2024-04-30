import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'movies_search_query_notifier.g.dart';

@riverpod
class MoviesSearchQueryNotifier extends _$MoviesSearchQueryNotifier {
  Timer? _debounceTimer;

  @override
  String build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return '';
  }

  void setQuery(String query) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }
}
