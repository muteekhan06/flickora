import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../models/cinema_stack.dart';
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
import 'cine_ai_screen.dart';
import 'roulette_screen.dart';
import 'stacks_screen.dart';
import 'double_feature_screen.dart';
import 'awards_screen.dart';
import 'franchises_screen.dart';
import 'directors_screen.dart';
import 'trivia_screen.dart';
import 'costar_connection_screen.dart';
import 'palette_aesthetic_screen.dart';
import 'notifications_screen.dart';
import 'festivals_screen.dart';
import 'cinematography_lab_screen.dart';
import 'mystery_screening_screen.dart';
import 'quotes_vault_screen.dart';
import 'script_vault_screen.dart';
import 'achievements_screen.dart';
import '../services/storage_service.dart';

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
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: FlickoraTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            tooltip: 'CineAI Oracle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CineAiScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
            tooltip: 'Release Alerts & Radar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
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

              const SizedBox(height: 10),

              // Discovery Row 2: CineAI Oracle & Cinema Roulette
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'CineAI Oracle',
                        subtitle: 'AI film companion',
                        badge: 'Smart AI',
                        icon: Icons.auto_awesome,
                        gradientColors: const [Color(0xFF2E1A47), Color(0xFF160D23)],
                        borderColor: Colors.purpleAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CineAiScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Cinema Roulette',
                        subtitle: 'Spin & pick a film',
                        badge: 'Can\'t Decide?',
                        icon: Icons.casino_rounded,
                        gradientColors: const [Color(0xFF2A200B), Color(0xFF141006)],
                        borderColor: Colors.amber.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RouletteScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 3: Double Feature Marathon & Awards Season Vault
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Double Features',
                        subtitle: '2-film marathon pairings',
                        badge: 'Marathon',
                        icon: Icons.movie_filter_rounded,
                        gradientColors: const [Color(0xFF132B25), Color(0xFF091612)],
                        borderColor: Colors.tealAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DoubleFeatureScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Oscar & Awards',
                        subtitle: 'Academy Award winners',
                        badge: 'Gold Vault',
                        icon: Icons.military_tech_rounded,
                        gradientColors: const [Color(0xFF33200E), Color(0xFF170E06)],
                        borderColor: Colors.amberAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AwardsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 4: Cinematic Universes & Director Retrospectives
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Franchise Hub',
                        subtitle: 'MCU, Star Wars & Dune',
                        badge: 'Dual Order',
                        icon: Icons.hub_rounded,
                        gradientColors: const [Color(0xFF0F1E36), Color(0xFF070E1A)],
                        borderColor: Colors.blueAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FranchisesScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Auteur Spotlight',
                        subtitle: 'Nolan, Denis & Tarantino',
                        badge: 'Directors',
                        icon: Icons.videocam_rounded,
                        gradientColors: const [Color(0xFF26182C), Color(0xFF130B17)],
                        borderColor: Colors.purple.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DirectorsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 5: Cinephile IQ Quiz & Cinematography Palettes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Cinephile IQ',
                        subtitle: 'Daily 5-question trivia',
                        badge: 'XP & Streak',
                        icon: Icons.psychology_rounded,
                        gradientColors: const [Color(0xFF2E240D), Color(0xFF171206)],
                        borderColor: Colors.amber.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TriviaScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Color Palettes',
                        subtitle: 'Neon, Sepia & Pastel mood',
                        badge: 'Aesthetic',
                        icon: Icons.palette_rounded,
                        gradientColors: const [Color(0xFF0E2B2A), Color(0xFF061414)],
                        borderColor: Colors.cyanAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PaletteAestheticScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 6: Six Degrees Co-Stars & Cinema Stacks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Co-Star Path',
                        subtitle: '6 Degrees of connection',
                        badge: 'Cast Solver',
                        icon: Icons.connect_without_contact_rounded,
                        gradientColors: const [Color(0xFF192536), Color(0xFF0B111A)],
                        borderColor: Colors.tealAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoStarConnectionScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Cinema Stacks',
                        subtitle: 'Curated playlists & vaults',
                        badge: 'Editorial',
                        icon: Icons.collections_bookmark_rounded,
                        gradientColors: const [Color(0xFF301018), Color(0xFF140508)],
                        borderColor: FlickoraTheme.accentRed.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StacksScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 7: Film Festivals Circuit & Cinematography Framing Lab
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Festival Circuit',
                        subtitle: 'Cannes, Venice & Berlin',
                        badge: 'Palme d\'Or',
                        icon: Icons.festival_rounded,
                        gradientColors: const [Color(0xFF261D0C), Color(0xFF130E06)],
                        borderColor: Colors.amber.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FestivalsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Framing Lab',
                        subtitle: 'Dolly Zoom, Oners & Angles',
                        badge: 'Composition',
                        icon: Icons.camera_rounded,
                        gradientColors: const [Color(0xFF0F262E), Color(0xFF071217)],
                        borderColor: Colors.cyanAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CinematographyLabScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 8: Blind Mystery Screening & Quotes Vault
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Blind Screening',
                        subtitle: 'Don\'t judge by the poster',
                        badge: 'Mystery',
                        icon: Icons.theater_comedy_rounded,
                        gradientColors: const [Color(0xFF241530), Color(0xFF110A17)],
                        borderColor: Colors.purpleAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MysteryScreeningScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Quotes Vault',
                        subtitle: 'Legendary lines & quotes',
                        badge: 'Iconic Lines',
                        icon: Icons.format_quote_rounded,
                        gradientColors: const [Color(0xFF332014), Color(0xFF19100A)],
                        borderColor: Colors.orangeAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QuotesVaultScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Discovery Row 9: Screenplay Script Vault & Cinephile Trophies
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Script Vault',
                        subtitle: 'Read production drafts',
                        badge: 'Screenplay',
                        icon: Icons.description_rounded,
                        gradientColors: const [Color(0xFF1E2433), Color(0xFF0E121A)],
                        borderColor: Colors.blueAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScriptVaultScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureActionCard(
                        context: context,
                        title: 'Hall of Trophies',
                        subtitle: '25+ Badges & XP milestones',
                        badge: 'Achievements',
                        icon: Icons.emoji_events_rounded,
                        gradientColors: const [Color(0xFF2E260D), Color(0xFF171306)],
                        borderColor: Colors.amberAccent.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // On This Day in Cinema History Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_today_rounded, color: Colors.amberAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'On This Day in Cinema History',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'In 1994, Frank Darabont\'s "The Shawshank Redemption" completed its theatrical run, embarking on its journey to become IMDb\'s #1 film of all time.',
                              style: TextStyle(fontSize: 11, color: FlickoraTheme.textMuted, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

              // Curated Cinema Stacks (Themed Editorial Collections)
              if (watchlistProvider.stacks.isNotEmpty) ...[
                SectionHeader(
                  title: 'Curated Cinema Stacks',
                  subtitle: 'Themed collections & editorial vaults',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StacksScreen()),
                    );
                  },
                ),
                _buildStacksHorizontal(context, watchlistProvider.stacks),
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

  Widget _buildStacksHorizontal(BuildContext context, List<CinemaStack> stacks) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: stacks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final stack = stacks[i];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StackDetailScreen(stack: stack)),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 210,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(stack.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stack.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stack.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: FlickoraTheme.textMuted, height: 1.3),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${stack.items.length} titles',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlickoraTheme.accentRed),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white54),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
