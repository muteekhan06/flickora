import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../providers/watchlist_provider.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class CineAiMessage {
  final String text;
  final bool isUser;
  final List<MediaItem>? mediaCards;
  final DateTime timestamp;

  CineAiMessage({
    required this.text,
    required this.isUser,
    this.mediaCards,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class CineAiScreen extends StatefulWidget {
  const CineAiScreen({super.key});

  @override
  State<CineAiScreen> createState() => _CineAiScreenState();
}

class _CineAiScreenState extends State<CineAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CineAiMessage> _messages = [];
  bool _isThinking = false;

  final List<String> _quickPrompts = [
    '🧠 Mind-bending thrillers with wild twists',
    '🌌 Cosmic sci-fi with Hans Zimmer style scores',
    '☕ Atmospheric neo-noir & rainy night mysteries',
    '🍿 90-minute comedies for high laughs',
    '💎 Overlooked indie masterpieces from A24',
    '🏰 Epic historical sagas & grand battles',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      CineAiMessage(
        isUser: false,
        text: 'Greetings, Cinephile! I am **CineAI**, your personal Flickora cinema oracle. '
            'Whether you need a bespoke recommendation matching your mood, a deep explanation of an ambiguous ending, '
            'or hidden gems from global archives, tell me what you crave tonight.',
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserMessage(String userText) async {
    final text = userText.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(CineAiMessage(text: text, isUser: true));
      _isThinking = true;
    });
    _scrollToBottom();

    final tmdb = context.read<TmdbService>();
    final lower = text.toLowerCase();

    // Query analysis
    List<MediaItem> matches = [];
    String aiResponse = '';

    await Future.delayed(const Duration(milliseconds: 650));

    try {
      if (lower.contains('twist') || lower.contains('mind') || lower.contains('thrill') || lower.contains('psychological')) {
        matches = await tmdb.getDiscoverMovies(genreId: 53); // Thriller
        if (matches.isEmpty) matches = await tmdb.getDiscoverMovies(genreId: 878);
        aiResponse = "Here are curated mind-bending masterworks that toy with perception, memory, and suspense. "
            "Every frame builds toward an unforgettable narrative reveal:";
      } else if (lower.contains('sci-fi') || lower.contains('space') || lower.contains('cosmic') || lower.contains('score') || lower.contains('soundtrack')) {
        matches = await tmdb.getDiscoverMovies(genreId: 878); // Sci-Fi
        aiResponse = "For breathtaking cosmic scale and awe-inspiring sound design, these cinematic journeys "
            "blend existential philosophical depths with visionary visuals:";
      } else if (lower.contains('comedy') || lower.contains('laugh') || lower.contains('fun') || lower.contains('comfort')) {
        matches = await tmdb.getDiscoverMovies(genreId: 35); // Comedy
        aiResponse = "These feel-good, sharply written features deliver effortless entertainment, high wit, and great replay value:";
      } else if (lower.contains('noir') || lower.contains('mystery') || lower.contains('crime') || lower.contains('detective')) {
        matches = await tmdb.getDiscoverMovies(genreId: 80); // Crime
        aiResponse = "Immerse yourself in shadows, rain-soaked city streets, and morally complex investigations with these neo-noir classics:";
      } else if (lower.contains('a24') || lower.contains('indie') || lower.contains('gem') || lower.contains('art')) {
        matches = await tmdb.getTopRatedMovies();
        aiResponse = "Exceptional director-driven visions with intimate storytelling, raw cinematography, and indelible resonance:";
      } else {
        // Fallback search or trending
        matches = await tmdb.searchMulti(text);
        if (matches.isEmpty) {
          matches = await tmdb.getTrending();
        }
        aiResponse = "Based on your prompt, here is a hand-picked selection curated from global cinema records:";
      }
    } catch (_) {
      matches = tmdb.getFreeCinema();
      aiResponse = "Here are premier picks from our collection ready to stream immediately:";
    }

    if (mounted) {
      setState(() {
        _isThinking = false;
        _messages.add(
          CineAiMessage(
            text: aiResponse,
            isUser: false,
            mediaCards: matches.take(4).toList(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        backgroundColor: FlickoraTheme.bgSurface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: FlickoraTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CineAI Oracle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'AI Cinema Companion • Online',
                      style: TextStyle(fontSize: 10.5, color: FlickoraTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Clear Conversation',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  CineAiMessage(
                    isUser: false,
                    text: 'Conversation reset. What cinematic vibe or director would you like to explore now?',
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Thinking indicator
          if (_isThinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: FlickoraTheme.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: FlickoraTheme.accentRed),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'CineAI is searching the film vault...',
                          style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Quick Prompt Pills
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                return ActionChip(
                  backgroundColor: FlickoraTheme.bgSurface,
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  label: Text(
                    _quickPrompts[i],
                    style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                  ),
                  onPressed: () => _handleUserMessage(_quickPrompts[i]),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.only(left: 14, right: 8, top: 10, bottom: 14),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgSurface,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlickoraTheme.bgCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleUserMessage,
                        decoration: InputDecoration(
                          hintText: 'Ask CineAI for movie advice, plot twists...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12.5),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: FlickoraTheme.primaryGradient,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _handleUserMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(CineAiMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: FlickoraTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.45),
              ),
            ),

            // Embedded Media Cards
            if (msg.mediaCards != null && msg.mediaCards!.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 195,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: msg.mediaCards!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final item = msg.mediaCards![i];
                    return _buildAiMediaCard(item);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiMediaCard(MediaItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(media: item)),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: FlickoraTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.black26),
                    errorWidget: (_, __, ___) => Container(color: Colors.black26),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            item.formattedRating,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.releaseYear} • ${item.genreNames.isNotEmpty ? item.genreNames.first : 'Cinema'}',
                    style: const TextStyle(fontSize: 9.5, color: FlickoraTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
