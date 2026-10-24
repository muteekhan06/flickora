import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import 'player_screen.dart';

class PartyChatMessage {
  final String sender;
  final String text;
  final bool isHost;
  final DateTime time;

  PartyChatMessage({
    required this.sender,
    required this.text,
    this.isHost = false,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class WatchPartyScreen extends StatefulWidget {
  final MediaItem media;

  const WatchPartyScreen({super.key, required this.media});

  @override
  State<WatchPartyScreen> createState() => _WatchPartyScreenState();
}

class _WatchPartyScreenState extends State<WatchPartyScreen> {
  final String _roomCode = 'FLK-${DateTime.now().millisecond.toString().padLeft(3, '0')}';
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<PartyChatMessage> _messages = [
    PartyChatMessage(sender: 'Alex (Host)', text: 'Welcome everyone to tonight\'s cinema screening! 🍿', isHost: true),
    PartyChatMessage(sender: 'Maya', text: 'Excited! I\'ve wanted to see this in high quality for weeks.'),
    PartyChatMessage(sender: 'David', text: 'The sound mix on this is legendary. Turn volume up! 🔊'),
  ];

  final List<String> _emojis = ['🍿', '🔥', '😱', '🤯', '👏', '❤️'];
  String? _floatingEmoji;
  Timer? _emojiTimer;

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _emojiTimer?.cancel();
    super.dispose();
  }

  void _triggerEmoji(String emoji) {
    setState(() {
      _floatingEmoji = emoji;
    });
    _emojiTimer?.cancel();
    _emojiTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _floatingEmoji = null);
    });
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    setState(() {
      _messages.add(PartyChatMessage(sender: 'You', text: text));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: FlickoraTheme.accentRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: FlickoraTheme.accentRed.withOpacity(0.5)),
              ),
              child: Text(
                _roomCode,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: FlickoraTheme.accentRed, letterSpacing: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.media.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white70),
            tooltip: 'Invite Friends',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Watch Party Room code $_roomCode copied to clipboard!'),
                  backgroundColor: FlickoraTheme.bgCardHighlight,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Player Container
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlayerScreen(
                  media: widget.media,
                  directStreamUrl: widget.media.directStreamUrl,
                  initialVideoKey: widget.media.trailerKey,
                ),

                // Floating live emoji reaction
                if (_floatingEmoji != null)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.5),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Text(
                            _floatingEmoji!,
                            style: const TextStyle(fontSize: 54),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Participants Header & Emoji Reaction Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: FlickoraTheme.bgSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_rounded, size: 16, color: Colors.greenAccent),
                    const SizedBox(width: 6),
                    const Text(
                      '4 Watching Live',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
                // Emoji Reaction Buttons
                Row(
                  children: _emojis.map((e) {
                    return GestureDetector(
                      onTap: () => _triggerEmoji(e),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(e, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Live Chat Feed
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isMe = msg.sender == 'You';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? FlickoraTheme.primaryRed : FlickoraTheme.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.sender,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.white70 : FlickoraTheme.accentRed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          msg.text,
                          style: const TextStyle(fontSize: 12.5, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat input bar
          Container(
            padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 14),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Share a live reaction or thought...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: FlickoraTheme.accentRed, size: 20),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
