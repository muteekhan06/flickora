import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../models/cast.dart';
import '../models/trailer.dart';
import '../models/episode.dart';
import '../models/watch_provider.dart';
import '../services/tmdb_service.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/custom_badge.dart';
import '../widgets/cast_card.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loader.dart';
import '../models/scene_bookmark.dart';
import '../models/release_reminder.dart';
import '../services/storage_service.dart';
import 'player_screen.dart';
import 'watch_party_screen.dart';
import 'palette_aesthetic_screen.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem media;

  const DetailScreen({super.key, required this.media});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late MediaItem _currentMedia;
  List<CastMember> _cast = [];
  List<VideoTrailer> _trailers = [];
  List<MediaItem> _similar = [];
  List<WatchProvider> _providers = [];
  List<Episode> _episodes = [];
  int _selectedSeason = 1;

  bool _isLoading = true;
  bool _isLoadingEpisodes = false;
  bool _isSynopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentMedia = widget.media;
    _loadAllDetails();
  }

  Future<void> _loadAllDetails() async {
    final service = context.read<TmdbService>();
    try {
      final detailsFuture = service.getMediaDetails(_currentMedia.id, _currentMedia.mediaType);
      final castFuture = service.getCredits(_currentMedia.id, _currentMedia.mediaType);
      final trailersFuture = service.getTrailers(_currentMedia.id, _currentMedia.mediaType);
      final similarFuture = service.getSimilar(_currentMedia.id, _currentMedia.mediaType);
      final providersFuture = service.getWatchProviders(_currentMedia.id, _currentMedia.mediaType);

      final results = await Future.wait([
        detailsFuture,
        castFuture,
        trailersFuture,
        similarFuture,
        providersFuture,
      ]);

      if (mounted) {
        setState(() {
          _currentMedia = results[0] as MediaItem;
          _cast = results[1] as List<CastMember>;
          _trailers = results[2] as List<VideoTrailer>;
          _similar = results[3] as List<MediaItem>;
          _providers = results[4] as List<WatchProvider>;
          _isLoading = false;
        });

        if (_currentMedia.mediaType == 'tv') {
          _loadSeasonEpisodes(1);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSeasonEpisodes(int seasonNum) async {
    setState(() {
      _selectedSeason = seasonNum;
      _isLoadingEpisodes = true;
    });

    final service = context.read<TmdbService>();
    try {
      final eps = await service.getSeasonEpisodes(_currentMedia.id, seasonNum);
      if (mounted) {
        setState(() {
          _episodes = eps;
          _isLoadingEpisodes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingEpisodes = false);
    }
  }

  void _playVideo({String? directUrl, String? videoKey, String? episodeTitle}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          media: _currentMedia,
          directStreamUrl: directUrl ?? _currentMedia.directStreamUrl,
          initialVideoKey: videoKey ??
              (_trailers.isNotEmpty ? _trailers.first.key : (_currentMedia.trailerKey ?? 'Way9Dexny3w')),
          episodeTitle: episodeTitle,
        ),
      ),
    );
  }

  void _showDownloadDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: FlickoraTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.download_rounded, color: FlickoraTheme.accentRed, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    'Download "${_currentMedia.title}"',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select offline playback resolution:',
                style: TextStyle(color: FlickoraTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildDownloadOption('1080p Full HD (Recommended)', '1.8 GB'),
              _buildDownloadOption('720p HD (Space Saver)', '850 MB'),
              _buildDownloadOption('4K Ultra HD HDR', '4.2 GB'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption(String title, String size) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.video_file_outlined, color: FlickoraTheme.textMuted),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white)),
      trailing: Text(size, style: const TextStyle(fontSize: 12, color: FlickoraTheme.accentRed)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading ${_currentMedia.title} ($title) for offline cinema play...'),
            backgroundColor: FlickoraTheme.bgCardHighlight,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showLogDiarySheet(BuildContext context) {
    final watchlistProvider = context.read<WatchlistProvider>();
    final existing = watchlistProvider.getEntry(_currentMedia.id);
    double selectedRating = existing?.rating ?? 4.5;
    final reviewController = TextEditingController(text: existing?.reviewText ?? '');
    bool isRewatch = existing?.rewatch ?? false;
    DateTime watchedDate = existing?.watchedDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlickoraTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _currentMedia.posterUrl,
                            width: 48,
                            height: 70,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: Colors.white10),
                            errorWidget: (_, __, ___) => Container(color: Colors.white10),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentMedia.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Log to personal Cinema Diary',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Star Rating',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = (index + 1).toDouble();
                        return IconButton(
                          iconSize: 36,
                          icon: Icon(
                            selectedRating >= starVal
                                ? Icons.star_rounded
                                : (selectedRating >= starVal - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setModalState(() {
                              selectedRating = starVal;
                            });
                          },
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        '${selectedRating.toStringAsFixed(1)} / 5.0 Stars',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Personal Review / Memory (Optional)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'What made this film memorable? Favorite scene, emotions...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                        filled: true,
                        fillColor: FlickoraTheme.bgCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: isRewatch,
                          activeColor: FlickoraTheme.primaryRed,
                          onChanged: (val) {
                            setModalState(() {
                              isRewatch = val ?? false;
                            });
                          },
                        ),
                        const Text(
                          'I have rewatched this title',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.bookmark_added_rounded, size: 20),
                        label: const Text('Save to Cinema Diary', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlickoraTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await watchlistProvider.logFilm(
                            media: _currentMedia,
                            rating: selectedRating,
                            reviewText: reviewController.text.trim(),
                            watchedDate: watchedDate,
                            rewatch: isRewatch,
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logged ${_currentMedia.title} (★${selectedRating.toStringAsFixed(1)}) to Cinema Diary!'),
                                backgroundColor: FlickoraTheme.bgCardHighlight,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTriviaSection() {
    final triviaList = _generateTrivia();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.lightbulb_rounded, size: 18, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Behind-the-Scenes & Trivia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...triviaList.map((t) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(t['emoji'] as String, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['category'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: FlickoraTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t['fact'] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<Map<String, dynamic>> _generateTrivia() {
    return [
      {
        'category': 'PRODUCTION & CAMERAWORK',
        'emoji': '🎥',
        'color': const Color(0x33E50914),
        'fact': 'Shot with high-dynamic-range digital cinema cameras to maximize deep shadow gradients and cinematic depth of field.',
      },
      {
        'category': 'DIRECTOR TRIVIA & EASTER EGG',
        'emoji': '🥚',
        'color': const Color(0x333B82F6),
        'fact': 'Features subtle homage frames referencing classic cinema masterworks that inspired the film\'s narrative climax.',
      },
      {
        'category': 'BOX OFFICE & CRITICAL ACCLAIM',
        'emoji': '⭐',
        'color': const Color(0x33EAB308),
        'fact': 'Scored an audience rating of ${_currentMedia.formattedRating}/10 across ${_currentMedia.voteCount} community reviews worldwide.',
      },
    ];
  }

  void _showAddToStackSheet(BuildContext context) {
    final watchlistProvider = context.read<WatchlistProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: FlickoraTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<WatchlistProvider>(
          builder: (context, provider, _) {
            final stacks = provider.stacks;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.collections_bookmark_rounded, color: FlickoraTheme.accentRed, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cinema Stack',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16, color: FlickoraTheme.accentRed),
                        label: const Text('New Stack', style: TextStyle(color: FlickoraTheme.accentRed, fontSize: 12)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCreateStackQuickDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (stacks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No stacks created yet', style: TextStyle(color: FlickoraTheme.textMuted)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: stacks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final stack = stacks[i];
                          final isIn = provider.isItemInStack(stack.id, _currentMedia.id);
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            tileColor: FlickoraTheme.bgCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isIn ? FlickoraTheme.primaryRed : Colors.white10),
                            ),
                            leading: Text(stack.emoji, style: const TextStyle(fontSize: 22)),
                            title: Text(
                              stack.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isIn ? FontWeight.bold : FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              '${stack.items.length} titles',
                              style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                            ),
                            trailing: Icon(
                              isIn ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              color: isIn ? FlickoraTheme.accentRed : Colors.white54,
                            ),
                            onTap: () async {
                              await provider.toggleItemInStack(stack.id, _currentMedia);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isIn
                                        ? 'Removed from ${stack.title}'
                                        : 'Added ${_currentMedia.title} to ${stack.title}!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateStackQuickDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FlickoraTheme.bgSurface,
        title: const Text('Create New Stack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. Nolan Epics, Dark Neo-Noir...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: FlickoraTheme.primaryRed),
            onPressed: () async {
              final t = titleController.text.trim();
              if (t.isNotEmpty) {
                await context.read<WatchlistProvider>().createStack(
                      title: t,
                      description: 'Custom curated collection',
                      emoji: '🎬',
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundtrackSection() {
    final composer = _getAssociatedComposer(_currentMedia.title);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.music_note_rounded, size: 20, color: Color(0xFF1DB954)),
                  SizedBox(width: 8),
                  Text(
                    'Original Motion Picture Soundtrack',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const Icon(Icons.equalizer_rounded, size: 18, color: Color(0xFF1DB954)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Composed by $composer',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Official symphonic orchestral score featuring iconic melodic suites and leitmotifs.',
            style: TextStyle(fontSize: 11.5, color: FlickoraTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.music_note, size: 16, color: Color(0xFF1DB954)),
                  label: const Text('Spotify Score', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1DB954)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final query = Uri.encodeComponent('${_currentMedia.title} Original Soundtrack $composer');
                    final uri = Uri.parse('https://open.spotify.com/search/$query');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.play_circle_fill, size: 16, color: FlickoraTheme.accentRed),
                  label: const Text('YouTube Music', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final query = Uri.encodeComponent('${_currentMedia.title} Soundtrack OST $composer');
                    final uri = Uri.parse('https://music.youtube.com/search?q=$query');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAssociatedComposer(String title) {
    final t = title.toLowerCase();
    if (t.contains('dune') || t.contains('oppenheimer')) return 'Ludwig Göransson';
    if (t.contains('interstellar') || t.contains('inception') || t.contains('dark knight') || t.contains('gladiator')) return 'Hans Zimmer';
    if (t.contains('star wars') || t.contains('jurassic') || t.contains('schindler')) return 'John Williams';
    if (t.contains('social network') || t.contains('dragon tattoo')) return 'Trent Reznor & Atticus Ross';
    if (t.contains('lord of the rings') || t.contains('hobbit')) return 'Howard Shore';
    if (t.contains('good, the bad') || t.contains('cinema paradiso')) return 'Ennio Morricone';
    return 'Hollywood Symphony Orchestra & Hans Zimmer';
  }

  Widget _buildParentalAdvisorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified_user_outlined, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Content & Age Advisory',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Text(
                  _currentMedia.voteAverage >= 8.0 ? 'PG-13 / TV-14' : 'PG / TV-PG',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildAdvisoryMeter('Violence & Intense Action', 0.65, Colors.orangeAccent),
          const SizedBox(height: 8),
          _buildAdvisoryMeter('Suspense, Fear & Thrills', 0.75, Colors.redAccent),
          const SizedBox(height: 8),
          _buildAdvisoryMeter('Profanity & Coarse Language', 0.40, Colors.amberAccent),
          const SizedBox(height: 8),
          _buildAdvisoryMeter('Romance & Sensuality', 0.30, Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _buildAdvisoryMeter(String label, double level, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary)),
            Text(
              level >= 0.7 ? 'Moderate-High' : (level >= 0.4 ? 'Moderate' : 'Mild'),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: level,
            minHeight: 4,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTechSpecsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.camera_alt_outlined, size: 18, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Text(
                'Camera & Technical Master Specs',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSpecRow('Aspect Ratio', '2.39:1 Scope (Anamorphic) / 1.43:1 IMAX'),
          const Divider(color: Colors.white10, height: 16),
          _buildSpecRow('Camera Systems', 'Arri Alexa 65 & IMAX MSM 9802 70mm'),
          const Divider(color: Colors.white10, height: 16),
          _buildSpecRow('Audio Formats', 'Dolby Atmos • IMAX 12-Track Digital Sound'),
          const Divider(color: Colors.white10, height: 16),
          _buildSpecRow('Color Mastering', 'Dolby Vision • DCI-P3 Wide Gamut 10-bit'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: FlickoraTheme.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildColorPaletteSection() {
    final colors = [
      const Color(0xFF1E2836),
      const Color(0xFF384A61),
      const Color(0xFFE50914),
      const Color(0xFFF3C07B),
      const Color(0xFF0F141C),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.palette_outlined, size: 18, color: Colors.amberAccent),
                  SizedBox(width: 8),
                  Text('Cinematography Palette', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PaletteAestheticScreen()));
                },
                child: const Text('Explore Aesthetic →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlickoraTheme.accentRed)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: colors.map((c) {
                final hex = '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
                return Expanded(
                  child: Container(
                    height: 40,
                    color: c,
                    alignment: Alignment.center,
                    child: Text(hex, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: c.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEasterEggsSection() {
    final secrets = [
      'IMAX camera rig was specially mounted on real vehicle chassis for maximum in-camera kinetic realism.',
      'Sound designers blended acoustic animal cries with custom orchestral cellos for tension scoring.',
      'Several dialogue exchanges in the third act were improvised on set and kept in the final theatrical cut.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_stories_outlined, size: 18, color: Colors.deepOrangeAccent),
              SizedBox(width: 8),
              Text('Behind-the-Scenes & Easter Eggs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          ...secrets.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.star_rate_rounded, size: 14, color: Colors.amberAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s, style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.35)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSceneBookmarksSection() {
    final bookmarks = StorageService().getSceneBookmarks(_currentMedia.id);
    if (bookmarks.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bookmark_added_rounded, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('Your Pinned Scene Bookmarks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Text('${bookmarks.length} Pinned', style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ...bookmarks.map((bm) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: FlickoraTheme.primaryRed, borderRadius: BorderRadius.circular(6)),
                  child: Text(bm.formattedTimecode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(bm.note, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.greenAccent, size: 20),
                  tooltip: 'Jump to scene in player',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          media: _currentMedia,
                          initialVideoKey: _currentMedia.trailerKey ?? 'Way9Dexny3w',
                          initialSeekSeconds: bm.seconds,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final isWatchlisted = watchlistProvider.isWatchlisted(_currentMedia.id);
    final isFav = watchlistProvider.isFavorite(_currentMedia.id);

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // Parallax Backdrop Header
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: FlickoraTheme.bgDark,
            leading: IconButton(
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? FlickoraTheme.accentRed : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => watchlistProvider.toggleFavorite(_currentMedia),
              ),
              IconButton(
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.share_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing Flickora link for ${_currentMedia.title}...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _currentMedia.backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: FlickoraTheme.bgCard),
                    errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: FlickoraTheme.darkFadeGradient,
                    ),
                  ),

                  // Center Play Button
                  Center(
                    child: GestureDetector(
                      onTap: () => _playVideo(),
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: FlickoraTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: FlickoraTheme.primaryRed.withOpacity(0.55),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Detail Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _currentMedia.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (_currentMedia.tagline != null && _currentMedia.tagline!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '"${_currentMedia.tagline}"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: FlickoraTheme.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Badges Row
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CustomBadge.rating(_currentMedia.formattedRating),
                      CustomBadge.quality(_currentMedia.hasDirectStream ? 'FREE FULL MOVIE' : (_currentMedia.voteAverage >= 8.0 ? '4K Ultra HD' : '1080p HD')),
                      CustomBadge(text: _currentMedia.releaseYear),
                      CustomBadge(text: _currentMedia.formattedRuntime),
                      CustomBadge(text: _currentMedia.mediaType.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons: Play Movie / Trailer, Diary Log, Watchlist, Download
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _playVideo(),
                          icon: Icon(
                            _currentMedia.hasDirectStream ? Icons.play_arrow_rounded : Icons.play_circle_fill_rounded,
                            size: 22,
                          ),
                          label: Text(
                            _currentMedia.hasDirectStream ? 'Watch Full Movie' : 'Watch Trailer',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlickoraTheme.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Log to Diary Button
                      Container(
                        decoration: BoxDecoration(
                          color: watchlistProvider.isLogged(_currentMedia.id)
                              ? const Color(0x33EAB308)
                              : FlickoraTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: watchlistProvider.isLogged(_currentMedia.id)
                                ? Colors.amber
                                : Colors.white12,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            watchlistProvider.isLogged(_currentMedia.id)
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                          ),
                          tooltip: 'Log to Cinema Diary',
                          onPressed: () => _showLogDiarySheet(context),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: isWatchlisted ? const Color(0x33E50914) : FlickoraTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isWatchlisted ? FlickoraTheme.primaryRed : Colors.white12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isWatchlisted ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                            color: isWatchlisted ? FlickoraTheme.accentRed : Colors.white,
                          ),
                          tooltip: 'Add to Watchlist',
                          onPressed: () => watchlistProvider.toggleWatchlist(_currentMedia),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Add to Cinema Stack Button
                      Container(
                        decoration: BoxDecoration(
                          color: FlickoraTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.collections_bookmark_outlined, color: Colors.white70),
                          tooltip: 'Add to Cinema Stack',
                          onPressed: () => _showAddToStackSheet(context),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: FlickoraTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.download_rounded, color: Colors.white),
                          tooltip: 'Offline Download',
                          onPressed: _showDownloadDialog,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Watch Party Button
                      Container(
                        decoration: BoxDecoration(
                          color: FlickoraTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.group_add_rounded, color: Colors.greenAccent),
                          tooltip: 'Watch Party Live',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => WatchPartyScreen(media: _currentMedia)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Release Reminder Bell
                      Container(
                        decoration: BoxDecoration(
                          color: StorageService().isReminderSet(_currentMedia.id) ? const Color(0x33FFC107) : FlickoraTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: StorageService().isReminderSet(_currentMedia.id) ? Colors.amber : Colors.white12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            StorageService().isReminderSet(_currentMedia.id) ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                            color: StorageService().isReminderSet(_currentMedia.id) ? Colors.amber : Colors.white,
                          ),
                          tooltip: 'Set Release Alert',
                          onPressed: () async {
                            final reminder = ReleaseReminder(
                              mediaId: _currentMedia.id,
                              title: _currentMedia.title,
                              releaseDate: _currentMedia.releaseDate ?? 'Coming Soon',
                              posterPath: _currentMedia.posterPath ?? '',
                              addedAt: DateTime.now(),
                            );
                            final added = await StorageService().toggleReminder(reminder);
                            setState(() {});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(added ? 'Release alert set for ${_currentMedia.title}!' : 'Release alert removed.'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Where to Stream Free / Watch Providers Section
                  if (_providers.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.live_tv_rounded, size: 16, color: FlickoraTheme.accentRed),
                        const SizedBox(width: 6),
                        const Text(
                          'Streaming Platforms & Free Providers',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _providers.map((p) {
                        return ActionChip(
                          backgroundColor: FlickoraTheme.bgSurface,
                          side: BorderSide(
                            color: p.type.contains('Free') ? FlickoraTheme.accentRed : Colors.white12,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.type.contains('Free') ? const Color(0x33E50914) : Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p.type,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: p.type.contains('Free') ? FlickoraTheme.accentRed : Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent('${_currentMedia.title} watch online on ${p.name}')}';
                            final uri = Uri.parse((p.link != null && p.link!.isNotEmpty) ? p.link! : searchUrl);
                            try {
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Streaming available on ${p.name}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Streaming on ${p.name} (${p.type})'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Synopsis Section
                  const Text(
                    'Storyline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isSynopsisExpanded = !_isSynopsisExpanded),
                    child: Text(
                      _currentMedia.overview,
                      maxLines: _isSynopsisExpanded ? null : 3,
                      overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: FlickoraTheme.textSecondary,
                      ),
                    ),
                  ),
                  if (_currentMedia.overview.length > 120) ...[
                    GestureDetector(
                      onTap: () => setState(() => _isSynopsisExpanded = !_isSynopsisExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _isSynopsisExpanded ? 'Show Less' : 'Read More',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: FlickoraTheme.accentRed,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // TV Series Season & Episode Drilldown Section
                  if (_currentMedia.mediaType == 'tv') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seasons & Episodes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        // Season pills
                        Row(
                          children: List.generate(
                            _currentMedia.numberOfSeasons > 0 ? _currentMedia.numberOfSeasons : 3,
                            (index) {
                              final season = index + 1;
                              final isSelected = _selectedSeason == season;
                              return GestureDetector(
                                onTap: () => _loadSeasonEpisodes(season),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? FlickoraTheme.primaryRed : FlickoraTheme.bgSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSelected ? FlickoraTheme.primaryRed : Colors.white12),
                                  ),
                                  child: Text(
                                    'S$season',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_isLoadingEpisodes)
                      ShimmerLoader(width: double.infinity, height: 100)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _episodes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ep = _episodes[index];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: FlickoraTheme.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: ep.stillUrl,
                                    width: 100,
                                    height: 65,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: FlickoraTheme.bgCardHighlight),
                                    errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ep.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Episode ${ep.episodeNumber} • ${ep.formattedDuration}',
                                        style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ep.overview,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.play_circle_fill_rounded, color: FlickoraTheme.primaryRed, size: 34),
                                  onPressed: () {
                                    _playVideo(
                                      directUrl: ep.streamUrl,
                                      episodeTitle: ep.name,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                  ],

                  // Cast & Crew with Tap to ActorScreen
                  if (_cast.isNotEmpty) ...[
                    const Text(
                      'Top Cast',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cast.length,
                        itemBuilder: (context, index) => CastCard(cast: _cast[index]),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Trailers & Clips List
                  if (_trailers.isNotEmpty) ...[
                    const Text(
                      'Trailers & Teasers',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _trailers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final trailer = _trailers[index];
                          return GestureDetector(
                            onTap: () => _playVideo(videoKey: trailer.key),
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: FlickoraTheme.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: trailer.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: FlickoraTheme.bgCardHighlight),
                                    errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                                  ),
                                  Container(color: Colors.black38),
                                  const Center(
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: FlickoraTheme.primaryRed,
                                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Text(
                                      trailer.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Behind-the-Scenes Trivia & Facts
                  _buildTriviaSection(),
                  const SizedBox(height: 20),

                  // Original Soundtrack & Score Vault
                  _buildSoundtrackSection(),
                  const SizedBox(height: 20),

                  // Parental Content & Age Advisory
                  _buildParentalAdvisorySection(),
                  const SizedBox(height: 20),

                  // Camera & Technical Master Specs
                  _buildTechSpecsSection(),
                  const SizedBox(height: 20),

                  // Cinematography Color Palette
                  _buildColorPaletteSection(),
                  const SizedBox(height: 20),

                  // Pinned Scene Bookmarks
                  _buildSceneBookmarksSection(),
                  const SizedBox(height: 20),

                  // Behind-the-Scenes & Easter Eggs
                  _buildEasterEggsSection(),
                  const SizedBox(height: 24),

                  // Similar Recommendations
                  if (_similar.isNotEmpty) ...[
                    const Text(
                      'More Like This',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _similar.take(6).length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          media: _similar[index],
                          width: double.infinity,
                          height: 155,
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
