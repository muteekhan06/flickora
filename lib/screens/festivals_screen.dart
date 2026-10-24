import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/festival_award.dart';
import 'detail_screen.dart';

class FestivalsScreen extends StatefulWidget {
  const FestivalsScreen({super.key});

  @override
  State<FestivalsScreen> createState() => _FestivalsScreenState();
}

class _FestivalsScreenState extends State<FestivalsScreen> {
  final List<FestivalAward> _allAwards = FestivalAward.getFestivalVault();
  String _selectedFestival = 'All';

  final List<String> _festivals = ['All', 'Cannes Film Festival', 'Venice International Film Festival', 'Berlin International Film Festival'];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFestival == 'All'
        ? _allAwards
        : _allAwards.where((a) => a.festivalName == _selectedFestival).toList();

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Global Film Festival Circuit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Festival Filter Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _festivals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final fest = _festivals[index];
                final isSelected = _selectedFestival == fest;
                return ChoiceChip(
                  label: Text(fest == 'All' ? 'All Festivals' : fest.replaceAll(' International Film Festival', '').replaceAll(' Film Festival', '')),
                  selected: isSelected,
                  selectedColor: FlickoraTheme.primaryRed,
                  backgroundColor: FlickoraTheme.bgSurface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : FlickoraTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: isSelected ? FlickoraTheme.primaryRed : Colors.white12),
                  onSelected: (_) => setState(() => _selectedFestival = fest),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Header Explainer Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF261D0C), FlickoraTheme.bgCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Text('🌿', style: TextStyle(fontSize: 32)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'World Festival Trophy Vault',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Palme d\'Or, Golden Lion, and Golden Bear winners celebrated for artistic purity.',
                        style: TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Festival Awards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final award = filtered[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(media: award.media)),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: award.media.posterUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(award.trophyIcon, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    award.awardName,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                                  child: Text(award.year, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              award.media.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Festival: ${award.festivalName}',
                              style: const TextStyle(fontSize: 10.5, color: FlickoraTheme.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Jury President: ${award.juryPresident}',
                              style: const TextStyle(fontSize: 10.5, color: FlickoraTheme.textMuted),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"${award.citation}"',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: FlickoraTheme.textSecondary, height: 1.3),
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
