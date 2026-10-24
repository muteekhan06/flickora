import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../providers/media_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_loader.dart';
import 'detail_screen.dart';
import 'player_screen.dart';
import 'mood_matcher_screen.dart';
import 'radar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xEE090A0E), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/flickora_logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => FlickoraTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'FLICKORA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: FlickoraTheme.accentRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: FlickoraTheme.accentRed.withOpacity(0.5), width: 0.8),
              ),
              child: const Text(
                'NO ADS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: FlickoraTheme.accentRed,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You are on the latest ad-free Flickora version 1.0.0!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: FlickoraTheme.bgCardHighlight,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => mediaProvider.refresh(),
        color: FlickoraTheme.primaryRed,
        backgroundColor: FlickoraTheme.bgSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Carousel
              if (mediaProvider.isLoading && mediaProvider.heroItems.isEmpty)
                ShimmerLoader(width: double.infinity, height: 440, borderRadius: 0)
              else
                HeroCarousel(items: mediaProvider.heroItems),

              const SizedBox(height: 16),

              // Interactive Discovery Features: Mood Matcher & Release Radar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Mood Matcher',
                        subtitle: 'What to watch tonight?',
                        badge: '3-Step Quiz',
                        icon: Icons.psychology_rounded,
                        gradientColors: const [Color(0xFFE50914), Color(0xFF8B0000)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MoodMatcherScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Release Radar',
                        subtitle: 'Box Office & Countdowns',
                        badge: 'Live Tracker',
                        icon: Icons.radar_rounded,
                        gradientColors: const [Color(0xFF1B2238), Color(0xFF101524)],
                        borderColor: FlickoraTheme.accentRed.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RadarScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Continue Watching Row (if any)
              if (watchlistProvider.continueWatching.isNotEmpty) ...[
                const SectionHeader(
                  title: 'Continue Watching',
                  subtitle: 'Pick up where you left off',
                ),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: watchlistProvider.continueWatching.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = watchlistProvider.continueWatching[index];
                      return _buildContinueWatchingCard(context, item);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Free Full-Length Movies (100% Free Full Stream)
              if (mediaProvider.freeCinema.isNotEmpty) ...[
                const SectionHeader(
                  title: 'Free Full-Length Movies',
                  subtitle: 'Stream entire cinema features instantly in-app',
                ),
                _buildHorizontalMovieList(mediaProvider.freeCinema),
                const SizedBox(height: 16),
              ],

              // Trending Now
              const SectionHeader(title: 'Trending Now', subtitle: 'What people are streaming today'),
              if (mediaProvider.isLoading && mediaProvider.trending.isEmpty)
                const ShimmerHorizontalList()
              else
                _buildHorizontalMovieList(mediaProvider.trending),

              const SizedBox(height: 16),

              // Top 10 Today
              if (mediaProvider.trending.length >= 10) ...[
                const SectionHeader(title: 'Top 10 Global Hits', subtitle: 'Most popular worldwide'),
                _buildTop10List(context, mediaProvider.trending.take(10).toList()),
                const SizedBox(height: 16),
              ],

              // Blockbuster Movies
              const SectionHeader(title: 'Blockbuster Movies', subtitle: 'Top rated cinematic features'),
              if (mediaProvider.isLoading && mediaProvider.popularMovies.isEmpty)
                const ShimmerHorizontalList()
              else
                _buildHorizontalMovieList(mediaProvider.popularMovies),

              const SizedBox(height: 16),

              // Binge-Worthy TV Series
              const SectionHeader(title: 'Binge-Worthy TV Series', subtitle: 'Critically acclaimed episodes'),
              if (mediaProvider.isLoading && mediaProvider.popularTV.isEmpty)
                const ShimmerHorizontalList()
              else
                _buildHorizontalMovieList(mediaProvider.popularTV),

              const SizedBox(height: 16),

              // Anime & Animation
              const SectionHeader(title: 'Anime Universe', subtitle: 'Epic animated stories'),
              if (mediaProvider.isLoading && mediaProvider.anime.isEmpty)
                const ShimmerHorizontalList()
              else
                _buildHorizontalMovieList(mediaProvider.anime),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<MediaItem> items) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return MovieCard(media: items[index]);
        },
      ),
    );
  }

  Widget _buildTop10List(BuildContext context, List<MediaItem> items) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final rank = index + 1;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(media: item)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              width: 180,
              child: Stack(
                children: [
                  // Overlapping big rank number
                  Positioned(
                    bottom: -10,
                    left: 0,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2230),
                        shadows: [
                          Shadow(
                            color: FlickoraTheme.primaryRed.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Poster shifted right
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: MovieCard(
                      media: item,
                      width: 130,
                      height: 190,
                      showTitle: false,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueWatchingCard(BuildContext context, dynamic continueItem) {
    final MediaItem media = continueItem.media;
    final double progress = continueItem.progress;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              media: media,
              initialVideoKey: media.trailerKey ?? 'Way9Dexny3w',
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: FlickoraTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop with play overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: media.backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: FlickoraTheme.bgCardHighlight),
                    errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.35),
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: FlickoraTheme.primaryRed,
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            LinearProgressIndicator(
              value: progress.clamp(0.05, 1.0),
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(FlickoraTheme.primaryRed),
              minHeight: 3.5,
            ),

            // Title and action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      media.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.more_vert, size: 16, color: FlickoraTheme.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> gradientColors,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor ?? Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
