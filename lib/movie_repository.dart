import 'package:dio/dio.dart';

class MovieRepository {
  const MovieRepository({required this.client, required this.apiKey});
  final Dio client;
  final String apiKey;

  Future<TMDBMoviesResponse> nowPlayingMovies({required int page}) async {
    final uri = Uri(
      scheme: 'https',
      host: 'api.themoviedb.org',
      path: '3/movie/now_playing',
      queryParameters: {
        'api_key': apiKey,
        'include_adult': 'false',
        'page': '$page',
      },
    );
  }
}
