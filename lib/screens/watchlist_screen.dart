import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../models/diary_entry.dart';
import '../providers/watchlist_provider.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'My Cinema Library',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: FlickoraTheme.primaryRed,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.white,
          unselectedLabelColor: FlickoraTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Watchlist (${provider.watchlist.length})'),
            Tab(text: 'Favorites (${provider.favorites.length})'),
            Tab(text: 'History (${provider.continueWatching.length})'),
            Tab(text: 'Diary & Stats (${provider.diary.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Watchlist tab
          _buildMediaList(
            items: provider.watchlist,
            emptyMessage: 'Your watchlist is empty.\nSave movies and shows you want to watch!',
            onRemove: (item) => provider.toggleWatchlist(item),
          ),

          // Favorites tab
          _buildMediaList(
            items: provider.favorites,
            emptyMessage: 'No favorites added yet.\nTap the heart icon on any title to favorite it!',
            onRemove: (item) => provider.toggleFavorite(item),
          ),

          // History tab
          _buildHistoryList(provider),

          // Diary & Stats tab
          _buildDiaryAndStatsTab(provider),
        ],
      ),
    );
  }

  Widget _buildDiaryAndStatsTab(WatchlistProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Cinema Stats Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlickoraTheme.primaryRed.withOpacity(0.15),
                  FlickoraTheme.bgCard,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FlickoraTheme.primaryRed.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'YOUR CINEMA STATS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: FlickoraTheme.accentRed, letterSpacing: 1),
                    ),
                    const Icon(Icons.analytics_outlined, color: FlickoraTheme.accentRed, size: 18),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatItem('Total Watchtime', provider.totalHoursLoggedString),
                    Container(width: 1, height: 36, color: Colors.white12),
                    _buildStatItem('Films Logged', '${provider.diary.length} Titles'),
                    Container(width: 1, height: 36, color: Colors.white12),
                    _buildStatItem('Top Genre', provider.topGenre),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Diary List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Watched Cinema Log',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '${provider.diary.length} logged',
                style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (provider.diary.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.edit_calendar_rounded, size: 54, color: Colors.white24),
                    SizedBox(height: 12),
                    Text(
                      'No films logged yet.\nTap "+ Log to Diary" on any title to record ratings and reviews!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.diary.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = provider.diary[index];
                return _buildDiaryCard(entry, provider);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: FlickoraTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry entry, WatchlistProvider provider) {
    final dateStr = DateFormat('MMM d, yyyy').format(entry.watchedDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: entry.media.posterUrl,
              width: 55,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: FlickoraTheme.bgCardHighlight),
              errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.media.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white30, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => provider.deleteDiary(entry.id),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (starIndex) {
                      final isFull = starIndex < entry.rating.floor();
                      return Icon(
                        isFull ? Icons.star_rounded : Icons.star_border_rounded,
                        color: FlickoraTheme.goldAccent,
                        size: 14,
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.rating} • $dateStr',
                      style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                    ),
                  ],
                ),
                if (entry.reviewText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${entry.reviewText}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: FlickoraTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaList({
    required List<MediaItem> items,
    required String emptyMessage,
    required Function(MediaItem) onRemove,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: FlickoraTheme.textMuted, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: Key('watchlist_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: FlickoraTheme.darkRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) => onRemove(item),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(media: item)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.posterUrl,
                      width: 60,
                      height: 85,
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
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.releaseYear} • ${item.genreNames.isNotEmpty ? item.genreNames.first : 'Cinema'}',
                          style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: FlickoraTheme.goldAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedRating,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: FlickoraTheme.primaryRed, size: 36),
                    onPressed: () {
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(WatchlistProvider provider) {
    final list = provider.continueWatching;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 64, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                'No watch history yet.\nStart streaming any title to track your progress!',
                textAlign: TextAlign.center,
                style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        final progressPercent = (item.progress * 100).toInt();

        return Dismissible(
          key: Key('history_${item.media.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: FlickoraTheme.darkRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) => provider.removeContinueWatching(item.media.id),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(
                    media: item.media,
                    initialVideoKey: item.media.trailerKey ?? 'Way9Dexny3w',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.media.posterUrl,
                      width: 60,
                      height: 85,
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
                          item.media.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: item.progress.clamp(0.05, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(FlickoraTheme.primaryRed),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$progressPercent% watched • Tap to resume',
                          style: const TextStyle(fontSize: 11, color: FlickoraTheme.accentRed, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded, color: FlickoraTheme.primaryRed, size: 36),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(
                            media: item.media,
                            initialVideoKey: item.media.trailerKey ?? 'Way9Dexny3w',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
