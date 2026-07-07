import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.compact = false,
  });

  final Movie movie;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'movie-poster-${movie.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PosterImage(posterPath: movie.posterPath),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _RatingPill(rating: movie.rating),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: compact ? 13 : 14,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class MovieListTile extends StatelessWidget {
  const MovieListTile({
    super.key,
    required this.movie,
    required this.onTap,
    this.enableHero = true,
    this.supportingText,
    this.trailing,
  });

  final Movie movie;
  final VoidCallback onTap;
  final bool enableHero;
  final String? supportingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _PosterFrame(movie: movie, enableHero: enableHero),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RatingPill(rating: movie.rating),
                  const SizedBox(height: 10),
                  Text(
                    supportingText ??
                        (movie.overview.isEmpty
                            ? 'Belum ada sinopsis untuk film ini.'
                            : movie.overview),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
          ],
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.posterPath});

  final String posterPath;

  @override
  Widget build(BuildContext context) {
    if (posterPath.isEmpty) {
      return DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF242429)),
        child: Icon(
          Icons.movie_creation_rounded,
          color: Colors.white.withValues(alpha: 0.35),
          size: 34,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: '${TMDBService.imageBaseUrl}$posterPath',
      fit: BoxFit.cover,
      placeholder: (context, url) => const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFF242429)),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF242429)),
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _PosterFrame extends StatelessWidget {
  const _PosterFrame({required this.movie, required this.enableHero});

  final Movie movie;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 76,
        height: 112,
        child: _PosterImage(posterPath: movie.posterPath),
      ),
    );

    if (!enableHero) {
      return poster;
    }

    return Hero(tag: 'movie-poster-${movie.id}', child: poster);
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC857)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
