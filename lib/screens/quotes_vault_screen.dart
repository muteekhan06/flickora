import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/cinema_quote.dart';

class QuotesVaultScreen extends StatefulWidget {
  const QuotesVaultScreen({super.key});

  @override
  State<QuotesVaultScreen> createState() => _QuotesVaultScreenState();
}

class _QuotesVaultScreenState extends State<QuotesVaultScreen> {
  final List<CinemaQuote> _quotes = CinemaQuote.getIconicQuotes();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _quotes.where((q) {
      final s = _searchQuery.toLowerCase();
      return q.quote.toLowerCase().contains(s) ||
          q.movieTitle.toLowerCase().contains(s) ||
          q.character.toLowerCase().contains(s) ||
          q.actor.toLowerCase().contains(s);
    }).toList();

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Iconic Cinema Quotes Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search quotes, movies, or characters...',
                hintStyle: const TextStyle(color: FlickoraTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: FlickoraTheme.textMuted),
                filled: true,
                fillColor: FlickoraTheme.bgSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Quotes List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final q = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(16),
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
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: q.posterUrl,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.movieTitle,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${q.character} (${q.actor}) • ${q.year}',
                                  style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Iconic Dialogue', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Copy Quote',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: '"${q.quote}" — ${q.character}, ${q.movieTitle} (${q.year})'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Quote copied to clipboard!'),
                                  backgroundColor: FlickoraTheme.accentRed,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"${q.quote}"',
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scene Context: ${q.sceneContext}',
                        style: const TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
