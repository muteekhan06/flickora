import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/diary_entry.dart';
import '../providers/watchlist_provider.dart';

class CinephilePassportScreen extends StatelessWidget {
  const CinephilePassportScreen({super.key});

  String _getCinephileRank(int minutes) {
    final hours = minutes ~/ 60;
    if (hours >= 100) return 'Legendary Grand Cinephile 👑';
    if (hours >= 50) return 'Grand Cinema Connoisseur 🏆';
    if (hours >= 20) return 'Avid Cinephile 🎬';
    if (hours >= 5) return 'Film Enthusiast 🍿';
    return 'Cinema Initiate 🎟️';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final diary = provider.diary;
    final totalMinutes = provider.totalMinutesLogged;
    final rank = _getCinephileRank(totalMinutes);
    final topGenre = provider.topGenre;
    final avgRating = provider.averageDiaryRating;

    // Top 4 rated films
    final sortedByRating = List<DiaryEntry>.from(diary)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final topPicks = sortedByRating.take(4).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Cinephile Passport',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Share Passport',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing your Flickora Cinephile Passport...'),
                  backgroundColor: FlickoraTheme.bgCardHighlight,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Passport Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF161922), Color(0xFF0F1118), Color(0xFF0A0C10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passport Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: FlickoraTheme.primaryGradient,
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                            ),
                            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'GLOBAL CINEMA PASSPORT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              Text(
                                'OFFICIAL FLICKORA ARCHIVES',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 1.2,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          'VERIFIED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 16),

                  // Rank Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CINEPHILE RANK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rank,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile('HOURS LOGGED', provider.totalHoursLoggedString, Icons.timer_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile('TITLES RATED', '${diary.length} Features', Icons.rate_review_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile('TOP GENRE', topGenre, Icons.category_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatTile(
                          'AVG STAR SCORE',
                          avgRating > 0 ? '★ ${avgRating.toStringAsFixed(1)} / 5.0' : 'Unrated',
                          Icons.star_outline_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Top Rated Masterpieces Section
                  if (topPicks.isNotEmpty) ...[
                    const Text(
                      'HALL OF FAME (YOUR TOP PICKS)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: topPicks.map((entry) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: entry.media.posterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: Colors.white10),
                                  errorWidget: (_, __, ___) => Container(color: Colors.white10),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '★ ${entry.rating.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Holographic Barcode Graphic
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: Colors.white38, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'FLK-2026-${diary.length.toString().padLeft(4, '0')}-CINEMA-PASS',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            letterSpacing: 2,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Share Passport Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text(
                  'Share My Cinephile Passport',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlickoraTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cinephile Passport generated! Ready to share.'),
                      backgroundColor: FlickoraTheme.bgCardHighlight,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: FlickoraTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: FlickoraTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
