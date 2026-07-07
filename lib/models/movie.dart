class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double rating;
  final String? notes;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.rating,
    this.notes,
  });

  Movie copyWith({
    int? id,
    String? title,
    String? posterPath,
    String? overview,
    double? rating,
    String? notes,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: _toInt(json['movie_id'] ?? json['id']),
      title: (json['title'] ?? '').toString(),
      posterPath: (json['poster_path'] ?? '').toString(),
      overview: (json['overview'] ?? '').toString(),
      rating: _toDouble(json['vote_average'] ?? json['rating']),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': id,
      'title': title,
      'poster_path': posterPath,
      'rating': rating,
      'notes': notes,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
