import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../widgets/custom_badge.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _spinTimer;

  bool _isSpinning = false;
  MediaItem? _selectedItem;
  MediaItem? _spinningDisplayItem;
  List<MediaItem> _pool = [];

  // Filters
  int? _selectedGenreId;
  double _minRating = 7.0;
  bool _freeOnly = false;

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Any Genre', 'id': null},
    {'name': 'Action ⚡', 'id': 28},
    {'name': 'Sci-Fi 🌌', 'id': 878},
    {'name': 'Thriller 😱', 'id': 53},
    {'name': 'Comedy 😂', 'id': 35},
    {'name': 'Drama 🎭', 'id': 18},
    {'name': 'Animation 🎨', 'id': 16},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadPool();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPool() async {
    final service = context.read<TmdbService>();
    try {
      List<MediaItem> items;
      if (_freeOnly) {
        items = service.getFreeCinema();
      } else if (_selectedGenreId != null) {
        items = await service.getDiscoverMovies(genreId: _selectedGenreId);
      } else {
        final trending = await service.getTrending();
        final top = await service.getTopRatedMovies();
        items = [...trending, ...top];
      }

      // Filter by min rating
      final filtered = items.where((i) => i.voteAverage >= _minRating).toList();

      if (mounted) {
        setState(() {
          _pool = filtered.isNotEmpty ? filtered : items;
          if (_selectedItem == null && _pool.isNotEmpty) {
            _selectedItem = _pool[Random().nextInt(_pool.length)];
            _spinningDisplayItem = _selectedItem;
          }
        });
      }
    } catch (_) {
      final fallback = service.getFreeCinema();
      if (mounted) {
        setState(() {
          _pool = fallback;
          _selectedItem = fallback.isNotEmpty ? fallback.first : null;
          _spinningDisplayItem = _selectedItem;
        });
      }
    }
  }

  void _spinTheReel() {
    if (_isSpinning || _pool.isEmpty) return;

    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    int ticks = 0;
    const maxTicks = 24;
    int intervalMs = 60;

    _spinTimer?.cancel();
    _spinTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      ticks++;
      if (mounted) {
        setState(() {
          _spinningDisplayItem = _pool[random.nextInt(_pool.length)];
        });
      }

      if (ticks >= maxTicks) {
        timer.cancel();
        final winner = _pool[random.nextInt(_pool.length)];
        if (mounted) {
          setState(() {
            _selectedItem = winner;
            _spinningDisplayItem = winner;
            _isSpinning = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Cinema Roulette',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            tooltip: 'How It Works',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: FlickoraTheme.bgSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Cinema Roulette', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: const Text(
                    'Can\'t decide what to watch tonight? Pick your preferred criteria, hit "Spin the Reel", and let Flickora randomly curate your next cinematic discovery.',
                    style: TextStyle(color: FlickoraTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Got it', style: TextStyle(color: FlickoraTheme.accentRed)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Filter Pills Row: Genre
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final g = _genres[i];
                  final isSelected = _selectedGenreId == g['id'];
                  return ChoiceChip(
                    label: Text(g['name'] as String),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedGenreId = g['id'];
                      });
                      _loadPool();
                    },
                    selectedColor: FlickoraTheme.primaryRed,
                    backgroundColor: FlickoraTheme.bgSurface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    side: BorderSide(color: isSelected ? FlickoraTheme.primaryRed : Colors.white12),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Rating & Free Cinema Toggle Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Min Rating: ${_minRating.toStringAsFixed(1)}+',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '100% Free Full Movies',
                        style: TextStyle(fontSize: 11.5, color: Colors.white70),
                      ),
                      Switch(
                        value: _freeOnly,
                        activeColor: FlickoraTheme.primaryRed,
                        onChanged: (val) {
                          setState(() => _freeOnly = val);
                          _loadPool();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reel Display Card
            Container(
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(
                color: FlickoraTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSpinning ? FlickoraTheme.accentRed : Colors.white12,
                  width: _isSpinning ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSpinning
                        ? FlickoraTheme.primaryRed.withOpacity(0.4)
                        : Colors.black.withOpacity(0.5),
                    blurRadius: _isSpinning ? 24 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _spinningDisplayItem != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: _spinningDisplayItem!.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.black38),
                          errorWidget: (_, __, ___) => Container(color: Colors.black38),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xCC090A0E), Color(0xFF090A0E)],
                              stops: [0.3, 0.7, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        if (_isSpinning)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: FlickoraTheme.accentRed),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: FlickoraTheme.accentRed),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'SPINNING REELS...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: [
                                  CustomBadge.rating(_spinningDisplayItem!.formattedRating),
                                  CustomBadge(text: _spinningDisplayItem!.releaseYear),
                                  if (_spinningDisplayItem!.hasDirectStream)
                                    CustomBadge.quality('FREE STREAM'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _spinningDisplayItem!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _spinningDisplayItem!.overview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: FlickoraTheme.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: FlickoraTheme.primaryRed),
                    ),
            ),

            const SizedBox(height: 24),

            // Big Spin Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.casino_rounded, size: 24, color: Colors.white),
                label: Text(
                  _isSpinning ? 'SPINNING...' : 'SPIN THE REEL',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlickoraTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: FlickoraTheme.primaryRed.withOpacity(0.5),
                ),
                onPressed: _isSpinning ? null : _spinTheReel,
              ),
            ),

            const SizedBox(height: 14),

            // Action Row: Watch Trailer or Details
            if (_selectedItem != null && !_isSpinning)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 20),
                      label: const Text('Play / Trailer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                              media: _selectedItem!,
                              directStreamUrl: _selectedItem!.directStreamUrl,
                              initialVideoKey: _selectedItem!.trailerKey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
                      label: const Text('Full Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlickoraTheme.bgSurface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(media: _selectedItem!)),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
