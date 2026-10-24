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
import 'player_screen.dart';

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

                  // Action Buttons: Play Movie / Trailer, Watchlist, Download
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
                      const SizedBox(width: 12),

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
                      const SizedBox(width: 12),

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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening stream on ${p.name}...'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
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
