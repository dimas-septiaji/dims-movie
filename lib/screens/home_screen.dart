import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/tmdb_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();
      if (provider.popularMovies.isEmpty) {
        provider.fetchPopularMovies();
      }
    });
  }

  void _openDetail(Movie movie) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.popularMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = provider.popularMovies;

          return RefreshIndicator(
            onRefresh: provider.fetchPopularMovies,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _HomeHeader(movieCount: movies.length),
                  ),
                ),

                if (movies.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Tarik untuk memuat film populer.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else ...[
                  // ── Auto-play Featured Carousel (hero besar di atas)
                  SliverToBoxAdapter(
                    child: _AutoCarousel(
                      movies: movies.take(8).toList(),
                      onMovieTap: _openDetail,
                    ),
                  ),

                  // ── Section: Popular Now - Horizontal Scroll
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: '🔥 Popular Now'),
                  ),
                  SliverToBoxAdapter(
                    child: _HorizontalMovieRow(
                      movies: movies,
                      onMovieTap: _openDetail,
                    ),
                  ),

                  // ── Section: Top Rated - Horizontal Scroll (subset berbeda)
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: '⭐ Top Rated'),
                  ),
                  SliverToBoxAdapter(
                    child: _HorizontalMovieRow(
                      movies: movies.reversed.toList(),
                      onMovieTap: _openDetail,
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.movieCount});

  final int movieCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dims Movie',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                movieCount == 0
                    ? 'Katalog film pilihan dari TMDB'
                    : '$movieCount film populer tersedia',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE50914),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE50914).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// AUTO-PLAY CAROUSEL (Hero besar berganti otomatis)
// ══════════════════════════════════════════════
class _AutoCarousel extends StatefulWidget {
  const _AutoCarousel({required this.movies, required this.onMovieTap});

  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;

  @override
  State<_AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<_AutoCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.movies.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        SizedBox(
          height: 310,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              final isActive = index == _currentPage;

              return AnimatedScale(
                scale: isActive ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _CarouselCard(
                    movie: movie,
                    onTap: () => widget.onMovieTap(movie),
                  ),
                ),
              );
            },
          ),
        ),

        // Dot Indicator
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.movies.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE50914)
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'movie-poster-${movie.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster
              movie.posterPath.isEmpty
                  ? const ColoredBox(color: Color(0xFF1A1A1F))
                  : CachedNetworkImage(
                      imageUrl:
                          '${TMDBService.imageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                    ),

              // Gradient overlay bawah
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Info teks di bawah
              Positioned(
                bottom: 18,
                left: 18,
                right: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC857), size: 15),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Populer',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HORIZONTAL SCROLL ROW (Kartu kecil scroll kanan-kiri)
// ══════════════════════════════════════════════
class _HorizontalMovieRow extends StatelessWidget {
  const _HorizontalMovieRow(
      {required this.movies, required this.onMovieTap});

  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 198,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (_, a) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _SmallMovieCard(
            movie: movie,
            onTap: () => onMovieTap(movie),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SMALL MOVIE CARD (untuk horizontal row)
// ══════════════════════════════════════════════
class _SmallMovieCard extends StatefulWidget {
  const _SmallMovieCard({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  State<_SmallMovieCard> createState() => _SmallMovieCardState();
}

class _SmallMovieCardState extends State<_SmallMovieCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.movie.posterPath.isEmpty
                          ? const ColoredBox(color: Color(0xFF242429))
                          : CachedNetworkImage(
                              imageUrl:
                                  '${TMDBService.imageBaseUrl}${widget.movie.posterPath}',
                              fit: BoxFit.cover,
                              placeholder: (_, u) => const ColoredBox(
                                  color: Color(0xFF242429)),
                              errorWidget: (_, u, e) => const Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white38),
                            ),
                      // Rating badge
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 11, color: Color(0xFFFFC857)),
                              const SizedBox(width: 2),
                              Text(
                                widget.movie.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
