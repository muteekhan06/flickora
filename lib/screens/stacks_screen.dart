import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/cinema_stack.dart';
import '../models/media_item.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/movie_card.dart';
import 'detail_screen.dart';

class StacksScreen extends StatelessWidget {
  const StacksScreen({super.key});

  void _showCreateStackDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedEmoji = '🍿';
    final emojis = ['🍿', '🌌', '⚡', '🧠', '🩸', '☕', '💎', '🎨', '🏰', '📼'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: FlickoraTheme.bgSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Create Cinema Stack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pick an Emoji Icon', style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: emojis.map((e) {
                        final isSel = selectedEmoji == e;
                        return GestureDetector(
                          onTap: () => setState(() => selectedEmoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel ? FlickoraTheme.primaryRed.withOpacity(0.3) : FlickoraTheme.bgCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSel ? FlickoraTheme.primaryRed : Colors.white10),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Stack Title',
                        labelStyle: const TextStyle(color: FlickoraTheme.textMuted),
                        hintText: 'e.g. Rainy Day Comfort Films',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: FlickoraTheme.bgCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle: const TextStyle(color: FlickoraTheme.textMuted),
                        hintText: 'What links these films together?',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: FlickoraTheme.bgCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: FlickoraTheme.primaryRed),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      await context.read<WatchlistProvider>().createStack(
                            title: title,
                            description: descController.text.trim(),
                            emoji: selectedEmoji,
                          );
                      if (context.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Create Stack', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final stacks = provider.stacks;

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Cinema Stacks',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: FlickoraTheme.accentRed),
            tooltip: 'Create New Stack',
            onPressed: () => _showCreateStackDialog(context),
          ),
        ],
      ),
      body: stacks.isEmpty
          ? const Center(
              child: Text('No cinema stacks found', style: TextStyle(color: FlickoraTheme.textMuted)),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: stacks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final stack = stacks[index];
                return _buildStackCard(context, stack);
              },
            ),
    );
  }

  Widget _buildStackCard(BuildContext context, CinemaStack stack) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StackDetailScreen(stack: stack)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FlickoraTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(stack.emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stack.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: stack.isEditorial ? const Color(0x33E50914) : Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stack.isEditorial ? 'EDITORIAL' : 'CUSTOM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: stack.isEditorial ? FlickoraTheme.accentRed : Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${stack.items.length} titles • curated by ${stack.curator}',
                        style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stack.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                stack.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.3),
              ),
            ],
            if (stack.items.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: stack.items.take(8).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = stack.items[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.posterUrl,
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.white10),
                        errorWidget: (_, __, ___) => Container(color: Colors.white10),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StackDetailScreen extends StatelessWidget {
  final CinemaStack stack;

  const StackDetailScreen({super.key, required this.stack});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    // Look up live stack from provider
    final liveStack = provider.stacks.firstWhere(
      (s) => s.id == stack.id,
      orElse: () => stack,
    );

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: Text(
          liveStack.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          if (!liveStack.isEditorial)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
              tooltip: 'Delete Stack',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: FlickoraTheme.bgSurface,
                    title: const Text('Delete Stack', style: TextStyle(color: Colors.white)),
                    content: Text('Are you sure you want to delete "${liveStack.title}"?', style: const TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: FlickoraTheme.primaryRed),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await provider.deleteStack(liveStack.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: liveStack.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(liveStack.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'No titles in "${liveStack.title}" yet',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add movies or TV shows to this stack from any title detail screen!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
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
              itemCount: liveStack.items.length,
              itemBuilder: (context, index) {
                return MovieCard(
                  media: liveStack.items[index],
                  width: double.infinity,
                  height: 155,
                );
              },
            ),
    );
  }
}
