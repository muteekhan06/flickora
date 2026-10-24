import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<MediaItem> _upcoming = [];

  final List<Map<String, dynamic>> _boxOfficeLeaders = [
    {
      'rank': 1,
      'title': 'Avatar',
      'year': '2009',
      'worldwideGross': '\$2.923 Billion',
      'domestic': '\$785 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/kyeqWdyUXW608qlYkRqosgbbJyK.jpg',
      'distributor': '20th Century Fox',
    },
    {
      'rank': 2,
      'title': 'Avengers: Endgame',
      'year': '2019',
      'worldwideGross': '\$2.799 Billion',
      'domestic': '\$858 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
      'distributor': 'Walt Disney Studios',
    },
    {
      'rank': 3,
      'title': 'Avatar: The Way of Water',
      'year': '2022',
      'worldwideGross': '\$2.320 Billion',
      'domestic': '\$684 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      'distributor': '20th Century Studios',
    },
    {
      'rank': 4,
      'title': 'Titanic',
      'year': '1997',
      'worldwideGross': '\$2.264 Billion',
      'domestic': '\$674 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg',
      'distributor': 'Paramount Pictures',
    },
    {
      'rank': 5,
      'title': 'Star Wars: The Force Awakens',
      'year': '2015',
      'worldwideGross': '\$2.071 Billion',
      'domestic': '\$936 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/wqnLdw3AyHa6Z721jwhFj51kRGL.jpg',
      'distributor': 'Walt Disney Studios',
    },
    {
      'rank': 6,
      'title': 'Avengers: Infinity War',
      'year': '2018',
      'worldwideGross': '\$2.052 Billion',
      'domestic': '\$678 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg',
      'distributor': 'Walt Disney Studios',
    },
    {
      'rank': 7,
      'title': 'Spider-Man: No Way Home',
      'year': '2021',
      'worldwideGross': '\$1.922 Billion',
      'domestic': '\$814 Million',
      'poster': 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
      'distributor': 'Sony Pictures',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUpcoming();
  }

  Future<void> _loadUpcoming() async {
    final service = TmdbService();
    try {
      final list = await service.getNowPlaying();
      if (mounted) {
        setState(() {
          _upcoming = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Radar & Box Office',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: FlickoraTheme.primaryRed,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: FlickoraTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Release Radar'),
            Tab(text: 'Global Box Office'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRadarList(),
          _buildBoxOfficeList(),
        ],
      ),
    );
  }

  Widget _buildRadarList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: FlickoraTheme.primaryRed));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _upcoming.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = _upcoming[index];
        final daysLeft = 14 + (index * 7);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(media: item)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: FlickoraTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  child: CachedNetworkImage(
                    imageUrl: item.posterUrl,
                    width: 90,
                    height: 125,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: FlickoraTheme.bgCardHighlight),
                    errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: FlickoraTheme.accentRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: FlickoraTheme.accentRed.withOpacity(0.4)),
                          ),
                          child: Text(
                            'PREMIERE IN $daysLeft DAYS',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: FlickoraTheme.accentRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Release: ${item.releaseDate}',
                          style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
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
                              child: const Row(
                                children: [
                                  Icon(Icons.play_circle_fill_rounded, color: FlickoraTheme.primaryRed, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Trailer',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoxOfficeList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _boxOfficeLeaders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = _boxOfficeLeaders[index];
        final rank = movie['rank'];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FlickoraTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rank <= 3 ? const Color(0x33FFB800) : Colors.white10,
                  border: Border.all(color: rank <= 3 ? FlickoraTheme.goldAccent : Colors.white24),
                ),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: rank <= 3 ? FlickoraTheme.goldAccent : Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: movie['poster'],
                  width: 50,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: FlickoraTheme.bgCardHighlight),
                  errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie['year']} • ${movie['distributor']}',
                      style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie['worldwideGross'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: FlickoraTheme.goldAccent),
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
