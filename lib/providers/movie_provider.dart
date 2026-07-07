import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../services/backend_service.dart';

class MovieProvider with ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();
  final BackendService _backendService = BackendService();

  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _watchlist = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _popularError;
  String? _searchError;
  String? _watchlistError;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchlist => _watchlist;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get popularError => _popularError;
  String? get searchError => _searchError;
  String? get watchlistError => _watchlistError;

  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    _popularError = null;
    notifyListeners();

    try {
      _popularMovies = await _tmdbService.getPopularMovies();
    } catch (e) {
      _popularError = _friendlyError(e);
      debugPrint('Error fetching popular movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      _searchError = _friendlyError(e);
      debugPrint('Error searching movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWatchlist() async {
    _isLoading = true;
    _watchlistError = null;
    notifyListeners();

    try {
      _watchlist = await _backendService.getWatchlist();
    } catch (e) {
      _watchlistError = _friendlyError(e);
      debugPrint('Error fetching watchlist: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> addToWatchlist(Movie movie) async {
    try {
      final success = await _backendService.addToWatchlist(movie);
      if (success) {
        _watchlist.insert(0, movie); // Optimistic UI update
        notifyListeners();
        return 'Berhasil ditambahkan ke watchlist';
      }
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Gagal menambahkan';
  }

  Future<String> updateWatchlist(Movie movie) async {
    try {
      final success = await _backendService.updateWatchlist(movie);
      if (success) {
        final index = _watchlist.indexWhere((item) => item.id == movie.id);
        if (index != -1) {
          _watchlist[index] = movie;
          notifyListeners();
        }
        return 'Watchlist berhasil diupdate';
      }
    } catch (e) {
      return _friendlyError(e);
    }
    return 'Gagal mengupdate watchlist';
  }

  Future<String> deleteFromWatchlist(Movie movie) async {
    try {
      final success = await _backendService.deleteFromWatchlist(movie.id);
      if (success) {
        _watchlist.removeWhere((item) => item.id == movie.id);
        notifyListeners();
        return 'Film dihapus dari watchlist';
      }
    } catch (e) {
      return _friendlyError(e);
    }
    return 'Gagal menghapus film';
  }

  String _friendlyError(Object error) {
    final message = error.toString().replaceAll('Exception: ', '');
    if (message.contains('TimeoutException')) {
      return 'Koneksi terlalu lama. Cek internet atau coba jaringan lain.';
    }
    if (message.contains('SocketException')) {
      return 'Tidak bisa terhubung ke server. Cek internet, DNS, atau coba jaringan lain.';
    }
    return message;
  }
}
