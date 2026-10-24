import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../providers/watchlist_provider.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class DoubleFeaturePair {
  final String title;
  final String theme;
  final String whyItWorks;
  final MediaItem film1;
  final MediaItem film2;
  final int totalMinutes;

  DoubleFeaturePair({
    required this.title,
    required this.theme,
    required this.whyItWorks,
    required this.film1,
    required this.film2,
    required this.totalMinutes,
  });
}

class DoubleFeatureScreen extends StatefulWidget {
  const DoubleFeatureScreen({super.key});

  @override
  State<DoubleFeatureScreen> createState() => _DoubleFeatureScreenState();
}

class _DoubleFeatureScreenState extends State<DoubleFeatureScreen> {
  bool _isLoading = true;
  List<DoubleFeaturePair> _pairs = [];

  @override
  void initState() {
    super.initState();
    _loadDoubleFeatures();
  }

  Future<void> _loadDoubleFeatures() async {
    final service = context.read<TmdbService>();
    try {
      final all = await service.getTopRatedMovies();
      final trending = await service.getTrending();
      final pool = [...all, ...trending];

      MediaItem getOrFallback(int index) {
        if (index < pool.length) return pool[index];
        return pool.isNotEmpty ? pool.first : service.getFreeCinema().first;
      }

      final f1 = getOrFallback(0);
      final f2 = getOrFallback(1);
      final f3 = getOrFallback(2);
      final f4 = getOrFallback(3);
      final f5 = getOrFallback(4);
      final f6 = getOrFallback(5);

      if (mounted) {
        setState(() {
          _pairs = [
            DoubleFeaturePair(
              title: 'Cosmic Wonder & Existential Horizons',
              theme: 'Hard Sci-Fi Masterclass',
              whyItWorks: 'Pairs the grand mathematical vastness of deep space exploration with intimate human emotional stakes and sweeping symphonic scores.',
              film1: f1,
              film2: f2,
              totalMinutes: 295,
            ),
            DoubleFeaturePair(
              title: 'Shadows, Rain & Moral Ambiguity',
              theme: 'Peak Neo-Noir Thrillers',
              whyItWorks: 'A masterclass in tension, high-contrast cinematography, and philosophical questions of justice in a fractured metropolis.',
              film1: f3,
              film2: f4,
              totalMinutes: 260,
            ),
            DoubleFeaturePair(
              title: 'High Octane Adrenaline & Precision Stunts',
              theme: 'Action Directing Royalty',
              whyItWorks: 'Relentless practical effects, revolutionary camera rigs, and edge-of-seat pacing that redefine modern blockbuster cinema.',
              film1: f5,
              film2: f6,
              totalMinutes: 245,
            ),
          ];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Double Features',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: FlickoraTheme.primaryRed))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _pairs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, i) {
                final pair = _pairs[i];
                return _buildPairCard(context, pair);
              },
            ),
    );
  }

  Widget _buildPairCard(BuildContext context, DoubleFeaturePair pair) {
    final hours = pair.totalMinutes ~/ 60;
    final mins = pair.totalMinutes % 60;

    return Container(
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FlickoraTheme.primaryRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: FlickoraTheme.primaryRed.withOpacity(0.5)),
                      ),
                      child: Text(
                        pair.theme.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: FlickoraTheme.accentRed,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '$hours hrs $mins m total',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pair.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  pair.whyItWorks,
                  style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),

          // Side-by-side posters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildFilmPoster(context, pair.film1, 'PART I')),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: FlickoraTheme.bgSurface,
                    child: Text('+', style: TextStyle(color: FlickoraTheme.accentRed, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                Expanded(child: _buildFilmPoster(context, pair.film2, 'PART II')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action row
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black26,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    label: const Text('Start Part I', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlickoraTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(
                            media: pair.film1,
                            directStreamUrl: pair.film1.directStreamUrl,
                            initialVideoKey: pair.film1.trailerKey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.collections_bookmark_rounded, color: Colors.white70, size: 18),
                    label: const Text('Save as Stack', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final provider = context.read<WatchlistProvider>();
                      await provider.createStack(
                        title: pair.title,
                        description: pair.whyItWorks,
                        emoji: '🍿',
                      );
                      final newStack = provider.stacks.first;
                      await provider.toggleItemInStack(newStack.id, pair.film1);
                      await provider.toggleItemInStack(newStack.id, pair.film2);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Created Cinema Stack: "${pair.title}"!'),
                            backgroundColor: FlickoraTheme.bgCardHighlight,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmPoster(BuildContext context, MediaItem item, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(media: item)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: item.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white10),
                  errorWidget: (_, __, ___) => Container(color: Colors.white10),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            '${item.releaseYear} • ★ ${item.formattedRating}',
            style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
