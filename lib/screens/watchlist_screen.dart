import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.fetchWatchlist,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  sliver: SliverToBoxAdapter(
                    child: _WatchlistHeader(count: provider.watchlist.length),
                  ),
                ),
                if (provider.isLoading && provider.watchlist.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.watchlist.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _WatchlistEmpty(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: provider.watchlist.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final movie = provider.watchlist[index];
                        return MovieListTile(
                          movie: movie,
                          onTap: () => _showNotesBottomSheet(context, movie),
                          enableHero: false,
                          supportingText: _notesPreview(movie),
                          trailing: IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_rounded),
                            color: const Color(0xFFE50914),
                            onPressed: () => _deleteMovie(movie),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showNotesBottomSheet(BuildContext ctx, Movie movie) async {
    final notesController = TextEditingController(text: movie.notes);
    final provider = ctx.read<MovieProvider>();

    final message = await showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var isSaving = false;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan: ${movie.title}',
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    enabled: !isSaving,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Misal: Terakhir nonton di menit 45...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              final newNotes = notesController.text.trim();

                              if (newNotes == (movie.notes ?? '').trim()) {
                                Navigator.pop(sheetContext);
                                return;
                              }

                              setSheetState(() => isSaving = true);
                              final updatedMovie = movie.copyWith(
                                notes: newNotes,
                              );
                              final result = await provider.updateWatchlist(
                                updatedMovie,
                              );

                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext, result);
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan Catatan',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );

    notesController.dispose();

    if (message != null && mounted) {
      _showSnack(message);
    }
  }

  String _notesPreview(Movie movie) {
    final notes = movie.notes?.trim();
    if (notes == null || notes.isEmpty) {
      return 'Ketuk untuk tambah catatan terakhir nonton.';
    }

    return 'Catatan: $notes';
  }

  Future<void> _deleteMovie(Movie movie) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus dari Watchlist?'),
          content: Text('Film "${movie.title}" akan dihapus dari watchlist.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    final message = await context.read<MovieProvider>().deleteFromWatchlist(
      movie,
    );
    if (!mounted) return;
    _showSnack(message);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _WatchlistHeader extends StatelessWidget {
  const _WatchlistHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Watchlist',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                '$count film',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Film yang kamu simpan dari halaman detail.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _WatchlistEmpty extends StatelessWidget {
  const _WatchlistEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 56,
            color: Colors.white.withValues(alpha: 0.34),
          ),
          const SizedBox(height: 16),
          Text(
            'Watchlist masih kosong',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan film dari halaman detail, lalu tarik untuk memuat ulang.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
