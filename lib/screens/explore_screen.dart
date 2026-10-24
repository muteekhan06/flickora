import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loader.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int? _selectedGenreId;
  String _selectedType = 'all'; // 'all', 'free', 'movie', 'tv', 'anime'
  bool _isLoading = false;
  List<MediaItem> _items = [];

  final List<Map<String, dynamic>> _genreChips = [
    {'id': null, 'name': 'All Genres'},
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 18, 'name': 'Drama'},
    {'id': 14, 'name': 'Fantasy'},
    {'id': 27, 'name': 'Horror'},
    {'id': 878, 'name': 'Sci-Fi'},
    {'id': 53, 'name': 'Thriller'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    setState(() => _isLoading = true);
    final service = context.read<TmdbService>();

    try {
      if (_selectedGenreId != null) {
        final res = await service.getByGenre(
          _selectedGenreId!,
          mediaType: _selectedType == 'tv' ? 'tv' : 'movie',
        );
        setState(() => _items = res);
      } else {
        if (_selectedType == 'free') {
          final res = service.getFreeCinema();
          setState(() => _items = res);
        } else if (_selectedType == 'movie') {
          final res = await service.getPopularMovies();
          setState(() => _items = res);
        } else if (_selectedType == 'tv') {
          final res = await service.getPopularTVShows();
          setState(() => _items = res);
        } else if (_selectedType == 'anime') {
          final res = await service.getAnime();
          setState(() => _items = res);
        } else {
          final res = await service.getTrending();
          setState(() => _items = res);
        }
      }
    } catch (_) {
      setState(() {
        _items = FlickoraConstants.fallbackMedia.map((m) => MediaItem.fromJson(m)).toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Explore Catalog',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Media Type segmented selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  _buildTypeTab('all', 'All'),
                  _buildTypeTab('free', 'Free Movies'),
                  _buildTypeTab('movie', 'Movies'),
                  _buildTypeTab('tv', 'Series'),
                  _buildTypeTab('anime', 'Anime'),
                ],
              ),
            ),
          ),

          // Genre filter chips horizontal list
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _genreChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genreChips[index];
                final isSelected = _selectedGenreId == genre['id'];
                return ChoiceChip(
                  label: Text(genre['name']),
                  selected: isSelected,
                  selectedColor: FlickoraTheme.primaryRed,
                  backgroundColor: FlickoraTheme.bgSurface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : FlickoraTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? FlickoraTheme.primaryRed : Colors.white10,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    setState(() {
                      _selectedGenreId = selected ? genre['id'] : null;
                    });
                    _loadCategory();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Catalog Grid
          Expanded(
            child: _isLoading
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 9,
                    itemBuilder: (_, __) => const ShimmerLoader(width: 100, height: 160),
                  )
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'No titles found in this category',
                          style: TextStyle(color: FlickoraTheme.textMuted),
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
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            media: _items[index],
                            width: double.infinity,
                            height: 155,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedGenreId = null;
          });
          _loadCategory();
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? FlickoraTheme.primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : FlickoraTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
