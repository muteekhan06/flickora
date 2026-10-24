import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class AwardWinnerItem {
  final int id;
  final String title;
  final String year;
  final String category;
  final String posterUrl;
  final double rating;
  final String accolades;
  final String director;
  final String overview;

  AwardWinnerItem({
    required this.id,
    required this.title,
    required this.year,
    required this.category,
    required this.posterUrl,
    required this.rating,
    required this.accolades,
    required this.director,
    required this.overview,
  });

  MediaItem toMediaItem() => MediaItem(
    id: id,
    title: title,
    overview: overview,
    posterPath: null,
    backdropPath: null,
    voteAverage: rating,
    voteCount: 12000,
    releaseDate: '$year-01-01',
    genreIds: [18],
    mediaType: 'movie',
  );
}

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AwardWinnerItem> _bestPicture = [
    AwardWinnerItem(
      id: 872585,
      title: 'Oppenheimer',
      year: '2024',
      category: 'Best Picture & Best Director',
      posterUrl: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      rating: 8.9,
      accolades: 'Won 7 Academy Awards including Best Picture, Director & Cinematography',
      director: 'Christopher Nolan',
      overview: 'The pulse-pounding biographical drama of the theoretical physicist who led the Manhattan Project.',
    ),
    AwardWinnerItem(
      id: 545611,
      title: 'Everything Everywhere All at Once',
      year: '2023',
      category: 'Best Picture & Best Director',
      posterUrl: 'https://image.tmdb.org/t/p/w500/w3LxiVYSTOxGlvd39w2qBm5e76x.jpg',
      rating: 8.8,
      accolades: 'Won 7 Academy Awards, most awarded film in cinema history',
      director: 'Daniels',
      overview: 'An aging Chinese immigrant is swept up in an insane adventure across the multiverse to save existence.',
    ),
    AwardWinnerItem(
      id: 496243,
      title: 'Parasite',
      year: '2020',
      category: 'Best Picture & Palme d\'Or',
      posterUrl: 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      rating: 8.5,
      accolades: 'First non-English film in history to win Academy Award for Best Picture',
      director: 'Bong Joon-ho',
      overview: 'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.',
    ),
    AwardWinnerItem(
      id: 157336,
      title: 'Interstellar',
      year: '2015',
      category: 'Best Visual Effects & Nominee',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      rating: 8.7,
      accolades: 'Academy Award Winner for Visual Effects & Landmark Sound Design',
      director: 'Christopher Nolan',
      overview: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
    ),
    AwardWinnerItem(
      id: 155,
      title: 'The Dark Knight',
      year: '2009',
      category: 'Academy Award Winner',
      posterUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      rating: 9.0,
      accolades: 'Won 2 Academy Awards including Best Supporting Actor (Heath Ledger)',
      director: 'Christopher Nolan',
      overview: 'Batman raises the stakes in his war on crime with the help of Lt. Jim Gordon and District Attorney Harvey Dent.',
    ),
    AwardWinnerItem(
      id: 122,
      title: 'The Lord of the Rings: The Return of the King',
      year: '2004',
      category: 'Best Picture (11 for 11 Sweep)',
      posterUrl: 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg',
      rating: 9.0,
      accolades: 'Swept all 11 Oscar nominations including Best Picture and Best Director',
      director: 'Peter Jackson',
      overview: 'Gandalf and Aragorn lead the World of Men against Sauron\'s army to draw his gaze from Frodo and Sam.',
    ),
  ];

  final List<AwardWinnerItem> _palmeDor = [
    AwardWinnerItem(
      id: 915935,
      title: 'Anatomy of a Fall',
      year: '2023',
      category: 'Cannes Palme d\'Or Winner',
      posterUrl: 'https://image.tmdb.org/t/p/w500/kQs6keheMwCxJxrzVHY5xYsRbgK.jpg',
      rating: 8.4,
      accolades: 'Palme d\'Or Winner at 76th Cannes Film Festival',
      director: 'Justine Triet',
      overview: 'A woman is suspected of her husband\'s murder, and their blind son faces a moral dilemma as the sole witness.',
    ),
    AwardWinnerItem(
      id: 496243,
      title: 'Parasite',
      year: '2019',
      category: 'Cannes Palme d\'Or (Unanimous)',
      posterUrl: 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      rating: 8.5,
      accolades: 'Won the Palme d\'Or unanimously by the jury presided by Alejandro González Iñárritu',
      director: 'Bong Joon-ho',
      overview: 'An exquisite social satire and psychological thriller set in modern Seoul.',
    ),
    AwardWinnerItem(
      id: 641,
      title: 'Apocalypse Now',
      year: '1979',
      category: 'Cannes Palme d\'Or Winner',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gQB8Y5RCMkv2zwzFHbUJX3kAhvA.jpg',
      rating: 8.3,
      accolades: 'Palme d\'Or Winner & 2 Academy Awards',
      director: 'Francis Ford Coppola',
      overview: 'A U.S. Army officer serving in Vietnam is tasked with assassinating a renegade Special Forces Colonel.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Awards & Oscar Vault',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          indicatorWeight: 3,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: FlickoraTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '🏆 Academy Awards'),
            Tab(text: '🌿 Cannes Palme d\'Or'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWinnerList(_bestPicture),
          _buildWinnerList(_palmeDor),
        ],
      ),
    );
  }

  Widget _buildWinnerList(List<AwardWinnerItem> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final item = list[i];
        final media = item.toMediaItem();
        return Container(
          decoration: BoxDecoration(
            color: FlickoraTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header laurel row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFFD4AF37).withOpacity(0.12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.military_tech_rounded, color: Color(0xFFD4AF37), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.year,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: item.posterUrl,
                        width: 80,
                        height: 120,
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
                            item.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Directed by ${item.director}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FlickoraTheme.accentRed),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${item.rating} / 10',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.accolades,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFD4AF37),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Button row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: Colors.black26,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.info_outline_rounded, size: 16, color: Colors.white70),
                      label: const Text('Details', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(media: media)),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                      label: const Text('Play Feature', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlickoraTheme.primaryRed,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerScreen(media: media)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
