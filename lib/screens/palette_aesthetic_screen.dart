import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../widgets/movie_card.dart';
import 'detail_screen.dart';

class AestheticGroup {
  final String title;
  final String subtitle;
  final String tag;
  final List<Color> palette;
  final String moodDescription;
  final List<MediaItem> sampleFilms;

  AestheticGroup({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.palette,
    required this.moodDescription,
    required this.sampleFilms,
  });
}

class PaletteAestheticScreen extends StatefulWidget {
  const PaletteAestheticScreen({super.key});

  @override
  State<PaletteAestheticScreen> createState() => _PaletteAestheticScreenState();
}

class _PaletteAestheticScreenState extends State<PaletteAestheticScreen> {
  int _selectedCategoryIndex = 0;

  final List<AestheticGroup> _groups = [
    AestheticGroup(
      title: 'Neon Cyberpunk & Synth Noir',
      subtitle: 'Electric high-contrast nightscapes',
      tag: 'Cyan & Magenta',
      palette: const [
        Color(0xFF0D0221),
        Color(0xFF0F084B),
        Color(0xFF26408B),
        Color(0xFF00F5D4),
        Color(0xFFFF007F),
      ],
      moodDescription: 'Drenched in futuristic neon rain, glowing holographic advertisements, and heavy synthetic contrast.',
      sampleFilms: [
        MediaItem(
          id: 335984,
          title: 'Blade Runner 2049',
          overview: 'Young Blade Runner K unearths a long-buried secret.',
          posterPath: '/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
          backdropPath: '/ilRyASDvt7vCTRdtV9z7909A6n9.jpg',
          voteAverage: 7.6,
          voteCount: 13000,
          releaseDate: '2017-10-04',
          genreIds: [878, 18],
          mediaType: 'movie',
        ),
        MediaItem(
          id: 603,
          title: 'The Matrix',
          overview: 'A computer hacker learns about the true nature of reality.',
          posterPath: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
          backdropPath: '/l4QHerTSbflqI8m5g1sL8P9t6n4.jpg',
          voteAverage: 8.2,
          voteCount: 25000,
          releaseDate: '1999-03-30',
          genreIds: [28, 878],
          mediaType: 'movie',
        ),
        MediaItem(
          id: 324857,
          title: 'Spider-Man: Into the Spider-Verse',
          overview: 'Teen Miles Morales becomes the new Spider-Man.',
          posterPath: '/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg',
          backdropPath: '/uUiId6cG32JSRjT6zUfZuu8y3t1.jpg',
          voteAverage: 8.4,
          voteCount: 15000,
          releaseDate: '2018-12-06',
          genreIds: [16, 28, 878],
          mediaType: 'movie',
        ),
      ],
    ),
    AestheticGroup(
      title: 'Pastel Whimsy & Symmetrical Dreams',
      subtitle: 'Wes Anderson & Studio Ghibli pastels',
      tag: 'Pink & Mint Vintage',
      palette: const [
        Color(0xFFFDE2E4),
        Color(0xFFFFCAD4),
        Color(0xFFB5E2FA),
        Color(0xFFEDD382),
        Color(0xFFF4A261),
      ],
      moodDescription: 'Meticulously framed center-weighted symmetry, nostalgic 60s soft pastels, and storybook charm.',
      sampleFilms: [
        MediaItem(
          id: 120467,
          title: 'The Grand Budapest Hotel',
          overview: 'Adventures of Gustave H, a legendary concierge at a famous European hotel.',
          posterPath: '/eWdyYQreja6JGCzqHWX9nz3UwNx.jpg',
          backdropPath: '/bB0K4Ue0xGkK28B101GZl5G9Qe0.jpg',
          voteAverage: 8.0,
          voteCount: 14000,
          releaseDate: '2014-02-26',
          genreIds: [35, 18],
          mediaType: 'movie',
        ),
        MediaItem(
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
        MediaItem(
          id: 346698,
          title: 'Barbie',
          overview: 'Barbie and Ken have the time of their lives in the colorful Barbieland.',
          posterPath: '/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
          backdropPath: '/nHf61UzkfFno5X1ofIhugCPus2R.jpg',
          voteAverage: 7.1,
          voteCount: 9000,
          releaseDate: '2023-07-19',
          genreIds: [35, 12],
          mediaType: 'movie',
        ),
      ],
    ),
    AestheticGroup(
      title: 'Golden Sunlit Dust & Arrakis Spice',
      subtitle: 'Warm sepia, deserts, and twilight horizons',
      tag: 'Amber & Terracotta',
      palette: const [
        Color(0xFF3D2614),
        Color(0xFF8B5A2B),
        Color(0xFFD48B38),
        Color(0xFFF3C07B),
        Color(0xFFFFE8A3),
      ],
      moodDescription: 'Expansive sand dunes, blazing golden hour sunsets, and warm cinematic 70mm grain.',
      sampleFilms: [
        MediaItem(
          id: 693134,
          title: 'Dune: Part Two',
          overview: 'Paul Atreides unites with Chani and the Fremen while seeking revenge.',
          posterPath: '/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
          backdropPath: '/xOMo8BRK7PfcJv9JCnx7s520DRq.jpg',
          voteAverage: 8.2,
          voteCount: 5000,
          releaseDate: '2024-02-27',
          genreIds: [878, 12],
          mediaType: 'movie',
        ),
        MediaItem(
          id: 76341,
          title: 'Mad Max: Fury Road',
          overview: 'An apocalyptic story set in the furthest reaches of our planet.',
          posterPath: '/8tZYtuWezp8JbcsvHYO0O46tFbo.jpg',
          backdropPath: '/nlCHUWda9OLCsYs5uvFTeKyFMTA.jpg',
          voteAverage: 7.6,
          voteCount: 22000,
          releaseDate: '2015-05-13',
          genreIds: [28, 12, 878],
          mediaType: 'movie',
        ),
        MediaItem(
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
      ],
    ),
    AestheticGroup(
      title: 'Cold Steel & Desaturated Monolith',
      subtitle: 'Minimalist frost, tungsten steel, and deep shadows',
      tag: 'Tungsten & Arctic Blue',
      palette: const [
        Color(0xFF0F141C),
        Color(0xFF1E2836),
        Color(0xFF384A61),
        Color(0xFF6B829E),
        Color(0xFFA8BDD1),
      ],
      moodDescription: 'Chilling, clinical precision, brutalist glass and concrete, and psychological isolation.',
      sampleFilms: [
        MediaItem(
          id: 155,
          title: 'The Dark Knight',
          overview: 'Batman raises the stakes in his war on crime.',
          posterPath: '/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
          backdropPath: '/dqK9Hag1054tghRQSqLSfrkvQnA.jpg',
          voteAverage: 8.5,
          voteCount: 32000,
          releaseDate: '2008-07-16',
          genreIds: [18, 28, 80],
          mediaType: 'movie',
        ),
        MediaItem(
          id: 329865,
          title: 'Arrival',
          overview: 'A linguist works with the military to communicate with alien lifeforms.',
          posterPath: '/x2FJsf1ElAgr63Y3PNPtJrcmpoe.jpg',
          backdropPath: '/yIZ1xendyQcxY3nGazoS29vgNZu.jpg',
          voteAverage: 7.6,
          voteCount: 17000,
          releaseDate: '2016-11-10',
          genreIds: [18, 878],
          mediaType: 'movie',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeGroup = _groups[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Cinematography Palette & Aesthetics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Selector chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _groups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final group = _groups[index];
                final isSelected = _selectedCategoryIndex == index;
                return ChoiceChip(
                  label: Text(group.tag),
                  selected: isSelected,
                  selectedColor: FlickoraTheme.accentRed,
                  backgroundColor: FlickoraTheme.bgSurface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : FlickoraTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: isSelected ? FlickoraTheme.accentRed : Colors.white12),
                  onSelected: (_) => setState(() => _selectedCategoryIndex = index),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Palette Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeGroup.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  activeGroup.subtitle,
                  style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                ),
                const SizedBox(height: 16),

                // 5 Swatch Color Bars
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: activeGroup.palette.map((color) {
                      final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                      return Expanded(
                        child: Container(
                          height: 52,
                          color: color,
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            hex,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  activeGroup.moodDescription,
                  style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Matching Films Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.palette_outlined, size: 18, color: FlickoraTheme.accentRed),
                const SizedBox(width: 8),
                Text(
                  'Signature ${activeGroup.tag} Masterworks',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 250,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: activeGroup.sampleFilms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final media = activeGroup.sampleFilms[index];
                return MovieCard(media: media);
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
