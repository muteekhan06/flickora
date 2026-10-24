import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import 'player_screen.dart';

class MysteryFilm {
  final String enigmaticHook;
  final String genreTag;
  final String runtimeTag;
  final MediaItem media;

  MysteryFilm({
    required this.enigmaticHook,
    required this.genreTag,
    required this.runtimeTag,
    required this.media,
  });
}

class MysteryScreeningScreen extends StatefulWidget {
  const MysteryScreeningScreen({super.key});

  @override
  State<MysteryScreeningScreen> createState() => _MysteryScreeningScreenState();
}

class _MysteryScreeningScreenState extends State<MysteryScreeningScreen> {
  final List<MysteryFilm> _vault = [
    MysteryFilm(
      enigmaticHook: 'A grief-stricken astronaut voyages beyond the event horizon of a supermassive black hole to bridge the fourth dimension of love and gravity.',
      genreTag: 'Cosmic Sci-Fi / Epic Drama',
      runtimeTag: '2h 49m',
      media: MediaItem(
        id: 157336,
        title: 'Interstellar',
        overview: 'Exodus across wormholes and cosmic dust storms.',
        posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        backdropPath: '/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
        voteAverage: 8.4,
        voteCount: 35000,
        releaseDate: '2014-11-05',
        genreIds: [12, 18, 878],
        mediaType: 'movie',
      ),
    ),
    MysteryFilm(
      enigmaticHook: 'An elite thief who infiltrates subconscious dreams is tasked with the impossible: planting an idea rather than stealing one.',
      genreTag: 'Heist Thriller / Mind-Bender',
      runtimeTag: '2h 28m',
      media: MediaItem(
        id: 27205,
        title: 'Inception',
        overview: 'A thief who steals corporate secrets through dream-sharing technology.',
        posterPath: '/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
        backdropPath: '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
        voteAverage: 8.4,
        voteCount: 36000,
        releaseDate: '2010-07-15',
        genreIds: [28, 878, 12],
        mediaType: 'movie',
      ),
    ),
    MysteryFilm(
      enigmaticHook: 'A cursed young girl wanders into an opulent supernatural bathhouse ruled by ancient spirits, witches, and water dragons.',
      genreTag: 'Hand-Drawn Fantasy / Anime',
      runtimeTag: '2h 05m',
      media: MediaItem(
        id: 129,
        title: 'Spirited Away',
        overview: 'A 10-year-old girl wanders into a world ruled by spirits.',
        posterPath: '/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
        backdropPath: '/Ab8mkHmkYADjU7wQiOkia9BzGvS.jpg',
        voteAverage: 8.5,
        voteCount: 16000,
        releaseDate: '2001-07-20',
        genreIds: [16, 14, 10751],
        mediaType: 'movie',
      ),
    ),
    MysteryFilm(
      enigmaticHook: 'A theoretical physicist confronts the dual nature of human intellect: creating the power to end world war while unlocking the means of self-extinction.',
      genreTag: 'Historical Biopic / IMAX Masterpiece',
      runtimeTag: '3h 00m',
      media: MediaItem(
        id: 872585,
        title: 'Oppenheimer',
        overview: 'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb.',
        posterPath: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
        backdropPath: '/rM5Y09CghvQIA3ne2Y5EGaq3G8M.jpg',
        voteAverage: 8.1,
        voteCount: 9000,
        releaseDate: '2023-07-19',
        genreIds: [18, 36],
        mediaType: 'movie',
      ),
    ),
  ];

  late MysteryFilm _currentFilm;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _pickRandomFilm();
  }

  void _pickRandomFilm() {
    final rand = Random().nextInt(_vault.length);
    setState(() {
      _currentFilm = _vault[rand];
      _isRevealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Blind Mystery Screening', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Roll Another Mystery Film',
            onPressed: _pickRandomFilm,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mystery Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _isRevealed ? FlickoraTheme.primaryRed.withOpacity(0.25) : const Color(0xFF1E1728),
                      FlickoraTheme.bgCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isRevealed ? FlickoraTheme.accentRed : Colors.purpleAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: _isRevealed ? FlickoraTheme.primaryRed.withOpacity(0.3) : Colors.purple.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Blind Poster / Mystery Box
                    Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _isRevealed
                          ? CachedNetworkImage(imageUrl: _currentFilm.media.posterUrl, fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🎭', style: TextStyle(fontSize: 48)),
                                SizedBox(height: 8),
                                Text('CONCEALED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purpleAccent, letterSpacing: 1.5)),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_currentFilm.genreTag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_currentFilm.runtimeTag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Enigmatic Hook
                    Text(
                      '"${_currentFilm.enigmaticHook}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white, height: 1.5),
                    ),

                    if (_isRevealed) ...[
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 10),
                      Text(
                        _currentFilm.media.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⭐ ${_currentFilm.media.formattedRating} TMDB • Released ${_currentFilm.media.releaseYear}',
                        style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              if (!_isRevealed) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isRevealed = true),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Lift Curtain & Reveal Film'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(
                            media: _currentFilm.media,
                            initialVideoKey: _currentFilm.media.trailerKey ?? 'Way9Dexny3w',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: Text('Stream ${_currentFilm.media.title} Now'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
