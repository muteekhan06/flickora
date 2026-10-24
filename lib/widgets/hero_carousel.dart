import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../providers/watchlist_provider.dart';
import '../screens/detail_screen.dart';
import '../screens/player_screen.dart';

class HeroCarousel extends StatefulWidget {
  final List<MediaItem> items;

  const HeroCarousel({super.key, required this.items});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          options: CarouselOptions(
            height: 440,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 6),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final item = widget.items[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(media: item)),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  CachedNetworkImage(
                    imageUrl: item.backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: FlickoraTheme.bgCard,
                      child: const Center(
                        child: Icon(Icons.movie_filter_outlined, color: Colors.white24, size: 48),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: FlickoraTheme.bgCardHighlight,
                    ),
                  ),

                  // Gradient Dark Vignette
                  Container(
                    decoration: const BoxDecoration(
                      gradient: FlickoraTheme.darkFadeGradient,
                    ),
                  ),

                  // Overlay Content
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Genre tags
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: item.genreNames.take(3).map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24, width: 0.6),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons: Watch Trailer & Add to Watchlist
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Watch Trailer Button
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      media: item,
                                      initialVideoKey: item.trailerKey ?? 'Way9Dexny3w',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow_rounded, size: 22),
                              label: const Text(
                                'Watch Trailer',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Watchlist Button
                            Consumer<WatchlistProvider>(
                              builder: (context, watchlistProvider, _) {
                                final inWatchlist = watchlistProvider.isWatchlisted(item.id);
                                return OutlinedButton.icon(
                                  onPressed: () {
                                    watchlistProvider.toggleWatchlist(item);
                                  },
                                  icon: Icon(
                                    inWatchlist ? Icons.check_rounded : Icons.add_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    inWatchlist ? 'Added' : 'Watchlist',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: inWatchlist
                                        ? const Color(0x33E50914)
                                        : Colors.black.withOpacity(0.4),
                                    side: BorderSide(
                                      color: inWatchlist ? FlickoraTheme.primaryRed : Colors.white30,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Indicator Dots
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items.asMap().entries.map((entry) {
            final isSelected = _currentIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 22 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: isSelected ? FlickoraTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white24,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
