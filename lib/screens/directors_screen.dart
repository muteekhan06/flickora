import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/director_profile.dart';
import '../widgets/movie_card.dart';

class DirectorsScreen extends StatefulWidget {
  const DirectorsScreen({super.key});

  @override
  State<DirectorsScreen> createState() => _DirectorsScreenState();
}

class _DirectorsScreenState extends State<DirectorsScreen> {
  final List<DirectorProfile> _directors = DirectorProfile.getDirectors();
  late DirectorProfile _selectedDirector;

  @override
  void initState() {
    super.initState();
    _selectedDirector = _directors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Director & Auteur Spotlight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Director Avatar Row
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _directors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final d = _directors[index];
                final isSelected = _selectedDirector.id == d.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDirector = d),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? FlickoraTheme.accentRed : Colors.white24,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: CachedNetworkImageProvider(d.portraitUrl),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.name.split(' ').last,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : FlickoraTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Director Bio Card
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _selectedDirector.portraitUrl,
                        width: 70,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDirector.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Born ${_selectedDirector.birthYear} • ${_selectedDirector.nationality}',
                            style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Visionary Auteur', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _selectedDirector.bio,
                  style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.4),
                ),
                if (_selectedDirector.famousQuotes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FlickoraTheme.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      _selectedDirector.famousQuotes.first,
                      style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Directorial Hallmarks Checklist
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.movie_creation_outlined, size: 18, color: Colors.cyanAccent),
                    SizedBox(width: 8),
                    Text(
                      'Directorial Hallmarks & Visual Tropes',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._selectedDirector.hallmarks.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: FlickoraTheme.accentRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(h, style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.3)),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Masterworks Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDirector.name.split(' ').last}\'s Masterworks',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${_selectedDirector.filmography.length} Films',
                  style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
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
              itemCount: _selectedDirector.filmography.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final movie = _selectedDirector.filmography[index];
                return MovieCard(media: movie);
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
