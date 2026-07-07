import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class BackendService {
  static const String watchlistUrl =
      'https://dmovie.dimas-server.my.id/watchlist.php';

  Future<List<Movie>> getWatchlist() async {
    final response = await http
        .get(Uri.parse(watchlistUrl))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is! Map<String, dynamic> || data['data'] is! List) {
        throw Exception('Format data watchlist tidak valid');
      }

      final List results = data['data'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception(_responseMessage(response, 'Failed to load watchlist'));
    }
  }

  Future<bool> addToWatchlist(Movie movie) async {
    final response = await http
        .post(
          Uri.parse(watchlistUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(movie.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      return true; // Berhasil
    } else if (response.statusCode == 409) {
      throw Exception('Film sudah ada di watchlist');
    } else {
      throw Exception(
        _responseMessage(response, 'Gagal menambahkan ke watchlist'),
      );
    }
  }

  Future<bool> updateWatchlist(Movie movie) async {
    final response = await http
        .put(
          Uri.parse(watchlistUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(movie.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(_responseMessage(response, 'Gagal mengupdate watchlist'));
  }

  Future<bool> deleteFromWatchlist(int movieId) async {
    final uri = Uri.parse(
      watchlistUrl,
    ).replace(queryParameters: {'movie_id': movieId.toString()});
    final response = await http
        .delete(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(
      _responseMessage(response, 'Gagal menghapus dari watchlist'),
    );
  }

  String _responseMessage(http.Response response, String fallback) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {
      // Use fallback below when the server does not return JSON.
    }

    return '$fallback. Kode error: ${response.statusCode}';
  }
}
