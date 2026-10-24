import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/search_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loader.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  final List<String> _popularSuggestions = [
    'Dune', 'Oppenheimer', 'Spider-Man', 'Arcane', 'Batman', 'Interstellar', 'Shogun', 'Anime'
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchProvider>().search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: FlickoraTheme.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search movies, series, anime...',
                  hintStyle: const TextStyle(color: FlickoraTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: FlickoraTheme.accentRed),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: FlickoraTheme.textMuted, size: 20),
                          onPressed: () {
                            _controller.clear();
                            searchProvider.clearSearch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Search Suggestions & History (when query is empty)
          if (_controller.text.isEmpty && searchProvider.results.isEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search History (if any)
                    if (searchProvider.searchHistory.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Searches',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: FlickoraTheme.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => searchProvider.clearHistory(),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(fontSize: 12, color: FlickoraTheme.accentRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: searchProvider.searchHistory.map((query) {
                          return GestureDetector(
                            onTap: () {
                              _controller.text = query;
                              searchProvider.search(query);
                            },
                            child: Chip(
                              backgroundColor: FlickoraTheme.bgSurface,
                              label: Text(query, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              avatar: const Icon(Icons.history, size: 16, color: FlickoraTheme.textMuted),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.white10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Popular Searches
                    const Text(
                      'Trending Searches',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FlickoraTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _popularSuggestions.map((title) {
                        return ActionChip(
                          backgroundColor: FlickoraTheme.bgCard,
                          label: Text(title, style: const TextStyle(fontSize: 12, color: Colors.white)),
                          side: const BorderSide(color: Colors.white10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onPressed: () {
                            _controller.text = title;
                            searchProvider.search(title);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Search Results Grid
            Expanded(
              child: searchProvider.isLoading
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 6,
                      itemBuilder: (_, __) => const ShimmerLoader(width: 100, height: 160),
                    )
                  : searchProvider.results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 64, color: Colors.white24),
                              const SizedBox(height: 12),
                              Text(
                                'No titles found for "${_controller.text}"',
                                style: const TextStyle(color: FlickoraTheme.textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: searchProvider.results.length,
                          itemBuilder: (context, index) {
                            return MovieCard(
                              media: searchProvider.results[index],
                              width: double.infinity,
                              height: 155,
                            );
                          },
                        ),
            ),
          ],
        ],
      ),
    );
  }
}
