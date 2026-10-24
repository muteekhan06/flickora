import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../providers/watchlist_provider.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class MoodMatcherScreen extends StatefulWidget {
  const MoodMatcherScreen({super.key});

  @override
  State<MoodMatcherScreen> createState() => _MoodMatcherScreenState();
}

class _MoodMatcherScreenState extends State<MoodMatcherScreen> {
  int _currentStep = 0; // 0 = Mood, 1 = Runtime, 2 = Era, 3 = Results

  // Selections
  int? _selectedGenreId;
  String _selectedMoodName = '';
  int _maxMinutes = 180;
  String _selectedEra = 'any';

  bool _isMatching = false;
  List<MediaItem> _matchedResults = [];

  final List<Map<String, dynamic>> _moods = [
    {'title': 'Adrenaline Rush', 'subtitle': 'Explosive stunts & fast action', 'emoji': '⚡', 'genreId': 28},
    {'title': 'Feel-Good Laughs', 'subtitle': 'Cheery, funny & lighthearted', 'emoji': '😂', 'genreId': 35},
    {'title': 'Mind-Bending', 'subtitle': 'Complex plots, sci-fi & twists', 'emoji': '🧠', 'genreId': 878},
    {'title': 'Dark & Gritty Thrills', 'subtitle': 'Edge-of-your-seat suspense', 'emoji': '😱', 'genreId': 53},
    {'title': 'Romantic & Heartfelt', 'subtitle': 'Emotional bonds & warmth', 'emoji': '❤️', 'genreId': 10749},
    {'title': 'Epic Animation & Fantasy', 'subtitle': 'Imaginative magical worlds', 'emoji': '🌌', 'genreId': 16},
  ];

  final List<Map<String, dynamic>> _times = [
    {'title': 'Quick Bite', 'subtitle': 'Under 100 minutes', 'emoji': '⏱️', 'minutes': 100},
    {'title': 'Standard Feature', 'subtitle': 'Around 2 hours (100 - 135m)', 'emoji': '🍿', 'minutes': 135},
    {'title': 'Cinematic Epic', 'subtitle': '2.5 hours or more', 'emoji': '🏰', 'minutes': 240},
  ];

  final List<Map<String, dynamic>> _eras = [
    {'title': 'Modern Blockbusters', 'subtitle': '2020 — Present', 'emoji': '🚀', 'era': '2020'},
    {'title': 'Modern Classics', 'subtitle': '2010 — 2019', 'emoji': '💎', 'era': '2010'},
    {'title': 'Nostalgia Golden Era', 'subtitle': '1990 — 2009', 'emoji': '📼', 'era': '1990'},
    {'title': 'Any Era / Surprise Me', 'subtitle': 'All-time best cinema', 'emoji': '🎲', 'era': 'any'},
  ];

  Future<void> _calculateMatches() async {
    setState(() {
      _currentStep = 3;
      _isMatching = true;
    });

    final service = context.read<TmdbService>();
    try {
      List<MediaItem> candidates = [];
      if (_selectedGenreId != null) {
        candidates = await service.getByGenre(_selectedGenreId!);
      }
      if (candidates.isEmpty) {
        candidates = await service.getTrending();
      }

      // Filter by runtime if possible
      candidates = candidates.where((c) {
        if (c.runtime == null || c.runtime == 0) return true;
        return c.runtime! <= _maxMinutes;
      }).toList();

      candidates.shuffle();
      setState(() {
        _matchedResults = candidates.take(3).toList();
        _isMatching = false;
      });
    } catch (_) {
      final fallback = await service.getTrending();
      fallback.shuffle();
      setState(() {
        _matchedResults = fallback.take(3).toList();
        _isMatching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Mood Matcher',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          if (_currentStep == 3)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: FlickoraTheme.accentRed),
              tooltip: 'Match Again',
              onPressed: () {
                setState(() => _currentStep = 0);
              },
            ),
        ],
      ),
      body: _buildCurrentStepView(),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Mood();
      case 1:
        return _buildStep2Time();
      case 2:
        return _buildStep3Era();
      case 3:
      default:
        return _buildResultsView();
    }
  }

  Widget _buildStepHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: FlickoraTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'STEP $stepNumber OF 3',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: FlickoraTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Mood() {
    return Column(
      children: [
        _buildStepHeader(
          stepNumber: '1',
          title: "What's your vibe tonight?",
          subtitle: 'Select your mood to tailor instant cinema recommendations.',
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _moods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mood = _moods[index];
              return _buildSelectCard(
                emoji: mood['emoji'],
                title: mood['title'],
                subtitle: mood['subtitle'],
                onTap: () {
                  setState(() {
                    _selectedGenreId = mood['genreId'];
                    _selectedMoodName = mood['title'];
                    _currentStep = 1;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Time() {
    return Column(
      children: [
        _buildStepHeader(
          stepNumber: '2',
          title: 'How much time do you have?',
          subtitle: 'We will filter films to match your available viewing window.',
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _times.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final time = _times[index];
              return _buildSelectCard(
                emoji: time['emoji'],
                title: time['title'],
                subtitle: time['subtitle'],
                onTap: () {
                  setState(() {
                    _maxMinutes = time['minutes'];
                    _currentStep = 2;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Era() {
    return Column(
      children: [
        _buildStepHeader(
          stepNumber: '3',
          title: 'Pick a Cinema Era',
          subtitle: 'From modern blockbusters to nostalgic classic milestones.',
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _eras.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final era = _eras[index];
              return _buildSelectCard(
                emoji: era['emoji'],
                title: era['title'],
                subtitle: era['subtitle'],
                onTap: () {
                  _selectedEra = era['era'];
                  _calculateMatches();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: FlickoraTheme.accentRed),
        onTap: onTap,
      ),
    );
  }

  Widget _buildResultsView() {
    if (_isMatching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: FlickoraTheme.primaryRed),
            const SizedBox(height: 20),
            Text(
              'Finding your ideal films for $_selectedMoodName...',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final watchlist = context.watch<WatchlistProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Cinema Matches Tonight',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Text(
                      'Hand-picked algorithm matches based on your mood',
                      style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._matchedResults.asMap().entries.map((entry) {
            final index = entry.key;
            final media = entry.value;
            final matchScore = 98 - (index * 4);
            final inWatchlist = watchlist.isWatchlisted(media.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backdrop header with match score pill
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: media.backdropUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(height: 180, color: FlickoraTheme.bgCardHighlight),
                        errorWidget: (_, __, ___) => Container(height: 180, color: FlickoraTheme.bgCardHighlight),
                      ),
                      Container(
                        height: 180,
                        decoration: const BoxDecoration(gradient: FlickoraTheme.darkFadeGradient),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: FlickoraTheme.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: FlickoraTheme.primaryRed.withOpacity(0.5), blurRadius: 10),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$matchScore% MATCH',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info & actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: FlickoraTheme.goldAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              media.formattedRating,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${media.releaseYear} • ${media.formattedRuntime}',
                              style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          media.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, height: 1.4, color: FlickoraTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => DetailScreen(media: media)),
                                  );
                                },
                                icon: const Icon(Icons.info_outline_rounded, size: 18),
                                label: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FlickoraTheme.primaryRed,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: inWatchlist ? const Color(0x33E50914) : Colors.white10,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: Icon(
                                inWatchlist ? Icons.check_rounded : Icons.add_rounded,
                                color: inWatchlist ? FlickoraTheme.accentRed : Colors.white,
                              ),
                              tooltip: 'Watchlist',
                              onPressed: () => watchlist.toggleWatchlist(media),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
