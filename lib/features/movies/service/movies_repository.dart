import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_pagination/core/config/env.dart';
import 'package:riverpod_pagination/core/utils/cancel_token_ref.dart';
import 'package:riverpod_pagination/core/utils/dio_provider.dart';
import 'package:riverpod_pagination/features/movies/model/tmdb_movie.dart';
import 'package:riverpod_pagination/features/movies/model/tmdb_movies_response.dart';

part 'movies_repository.g.dart';

/// Metadata used when fetching movies with the paginated search API.
typedef MoviesQueryData = ({String query, int page});

final baseUri = Uri(
  scheme: 'https',
  host: 'api.themoviedb.org',
);

class MoviesRepository {
  const MoviesRepository({required this.client, required this.apiKey});
  final Dio client;
  final String apiKey;

  Map<String, dynamic> getBasicQueryParams() =>
      {'api_key': apiKey, 'include_adult': false};

  Future<TMDBMoviesResponse> searchMovies(
      {required MoviesQueryData queryData, CancelToken? cancelToken}) async {
    final uri = baseUri.replace(
      path: '3/search/movie',
      queryParameters: {
        ...getBasicQueryParams(),
        'page': '${queryData.page}',
        'query': queryData.query,
      },
    );

    final response = await client.getUri(uri, cancelToken: cancelToken);

    return TMDBMoviesResponse.fromJson(response.data);
  }

  Future<TMDBMoviesResponse> nowPlayingMovies(
      {required int page, CancelToken? cancelToken}) async {
    final uri = baseUri.replace(
      path: '3/movie/now_playing',
      queryParameters: {
        ...getBasicQueryParams(),
        'page': page,
      },
    );
    final response = await client.getUri(uri, cancelToken: cancelToken);
    return TMDBMoviesResponse.fromJson(response.data);
  }

  Future<TMDBMovie> movie(
      {required int movieId, CancelToken? cancelToken}) async {
    final url = baseUri
        .replace(
          path: '3/movie/$movieId',
          queryParameters: getBasicQueryParams(),
        )
        .toString();
    final response = await client.get(url, cancelToken: cancelToken);
    return TMDBMovie.fromJson(response.data);
  }
}

@riverpod
MoviesRepository moviesRepository(MoviesRepositoryRef ref) =>
    MoviesRepository(client: ref.watch(dioProvider), apiKey: Env.tmdbAPIKey);

class AbortedException implements Exception {}

/// Provider to fetch a movie by ID
@riverpod
Future<TMDBMovie> movie(
  MovieRef ref, {
  required int movieId,
}) {
  final cancelToken = ref.cancelToken();
  return ref
      .watch(moviesRepositoryProvider)
      .movie(movieId: movieId, cancelToken: cancelToken);
}

/// Provider to fetch paginated movies data
@riverpod
Future<TMDBMoviesResponse> fetchMovies(
  FetchMoviesRef ref, {
  required MoviesQueryData queryData,
}) async {
  final moviesRepo = ref.watch(moviesRepositoryProvider);

  final cancelToken = CancelToken();

  final link = ref.keepAlive();

  Timer? timer;

  ref.onDispose(() {
    cancelToken.cancel();
    timer?.cancel();
  });

  ref.onCancel(() {
    timer = Timer(const Duration(seconds: 30), () {
      // dispose on timeout
      link.close();
    });
  });

  ref.onResume(() {
    timer?.cancel();
  });

  if (queryData.query.isEmpty) {
    // use non-search endpoint
    return moviesRepo.nowPlayingMovies(
      page: queryData.page,
      cancelToken: cancelToken,
    );
  } else {
    // use search endpoint
    return moviesRepo.searchMovies(
      queryData: queryData,
      cancelToken: cancelToken,
    );
  }
}
