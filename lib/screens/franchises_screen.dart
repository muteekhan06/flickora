import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/cinematic_universe.dart';
import '../providers/watchlist_provider.dart';
import 'detail_screen.dart';

class FranchisesScreen extends StatefulWidget {
  const FranchisesScreen({super.key});

  @override
  State<FranchisesScreen> createState() => _FranchisesScreenState();
}

class _FranchisesScreenState extends State<FranchisesScreen> {
  final List<CinematicUniverse> _universes = CinematicUniverse.getUniverses();
  late CinematicUniverse _selectedUniverse;
  bool _useChronologicalOrder = false;

  @override
  void initState() {
    super.initState();
    _selectedUniverse = _universes.first;
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final entries = _useChronologicalOrder ? _selectedUniverse.inChronologicalOrder : _selectedUniverse.inReleaseOrder;

    // Calculate watched count
    final watchedCount = entries.where((e) => watchlistProvider.isWatched(e.media.id)).length;
    final progress = entries.isEmpty ? 0.0 : watchedCount / entries.length;

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Cinematic Universes Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        children: [
          // Universe horizontal pills
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _universes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final u = _universes[index];
                final isSelected = _selectedUniverse.id == u.id;
                return ChoiceChip(
                  avatar: Text(u.icon, style: const TextStyle(fontSize: 14)),
                  label: Text(u.title),
                  selected: isSelected,
                  selectedColor: FlickoraTheme.primaryRed,
                  backgroundColor: FlickoraTheme.bgSurface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : FlickoraTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: isSelected ? FlickoraTheme.primaryRed : Colors.white10),
                  onSelected: (_) => setState(() => _selectedUniverse = u),
                );
              },
            ),
          ),

          // Universe Hero Banner with Progress Meter
          Container(
            margin: const EdgeInsets.all(16),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: CachedNetworkImageProvider(_selectedUniverse.bannerUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.darken),
              ),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(_selectedUniverse.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedUniverse.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedUniverse.description,
                  style: const TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Universe Watch Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Universe Progress: $watchedCount / ${entries.length} Watched',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                  ),
                ),
              ],
            ),
          ),

          // Order Switcher Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _useChronologicalOrder = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_useChronologicalOrder ? FlickoraTheme.primaryRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.theaters_outlined, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Release Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _useChronologicalOrder = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _useChronologicalOrder ? FlickoraTheme.primaryRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timeline_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Chronological Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timeline Entries
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isWatched = watchlistProvider.isWatched(entry.media.id);
              final stepNumber = index + 1;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(media: entry.media)),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isWatched ? Colors.green.withOpacity(0.4) : Colors.white10),
                  ),
                  child: Row(
                    children: [
                      // Step Pill & Poster
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: entry.media.posterUrl,
                              width: 65,
                              height: 95,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Text('#$stepNumber', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Metadata & Timeline Era
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.media.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isWatched)
                                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: FlickoraTheme.primaryRed.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.timelineEra,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlickoraTheme.accentRed),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.synopsisSnippet,
                              style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
