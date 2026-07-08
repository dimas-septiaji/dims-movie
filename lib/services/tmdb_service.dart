import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TMDBService {
  static const String accessToken = String.fromEnvironment(
    'TMDB_ACCESS_TOKEN',
  );
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static Map<String, String> get _headers {
    if (accessToken.isEmpty) {
      throw Exception(
        '--dart-define=TMDB_ACCESS_TOKEN=token_kamuTMDB_ACCESS_TOKEN belum diisi. Jalankan Flutter dengan ',
      );
    }

    return {
      'Authorization': 'Bearer $accessToken',
      'accept': 'application/json',
    };
  }

  Future<List<Movie>> getPopularMovies() async {
    final response = await http

        .get(
          Uri.parse('$baseUrl/movie/popular?language=en-US&page=1'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception(_errorMessage('Gagal memuat film populer', response));
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http
        .get(
          Uri.https('api.themoviedb.org', '/3/search/movie', {
            'query': query,
            'include_adult': 'false',
            'language': 'en-US',
            'page': '1',
          }),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception(_errorMessage('Gagal mencari film', response));
    }
  }

  String _errorMessage(String action, http.Response response) {
    String detail = response.body.trim();
    if (detail.length > 160) {
      detail = '${detail.substring(0, 160)}...';
    }

    return detail.isEmpty
        ? '$action. Kode error: ${response.statusCode}'
        : '$action. Kode error: ${response.statusCode}. $detail';
  }
}
