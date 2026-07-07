import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/tmdb_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.45),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _addToWatchlist,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.bookmark_add_rounded),
        label: Text(_isSaving ? 'Menyimpan' : 'Add to Watchlist'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroHeader(movie: movie)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            sliver: SliverList.list(
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.star_rounded,
                      label: '${movie.rating.toStringAsFixed(1)} / 10',
                      color: const Color(0xFFFFC857),
                    ),
                    const _InfoChip(
                      icon: Icons.local_movies_rounded,
                      label: 'Movie',
                      color: Color(0xFFE50914),
                    ),
                    const _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: 'TMDB',
                      color: Color(0xFFFF6B35),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Sinopsis',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  movie.overview.isEmpty
                      ? 'Sinopsis belum tersedia untuk film ini.'
                      : movie.overview,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.58,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToWatchlist() async {
    setState(() => _isSaving = true);

    final message = await context.read<MovieProvider>().addToWatchlist(
      widget.movie,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 470,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (movie.posterPath.isNotEmpty)
            CachedNetworkImage(
              imageUrl: '${TMDBService.imageBaseUrl}${movie.posterPath}',
              fit: BoxFit.cover,
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF1A1A1F)),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  const Color(0xFF0D0D0F),
                ],
                stops: const [0.25, 1],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Hero(
                  tag: 'movie-poster-${movie.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 132,
                      height: 196,
                      color: const Color(0xFF242429),
                      child: movie.posterPath.isEmpty
                          ? const Icon(Icons.movie_creation_rounded, size: 42)
                          : CachedNetworkImage(
                              imageUrl:
                                  '${TMDBService.imageBaseUrl}${movie.posterPath}',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Premium picks from TMDB',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
