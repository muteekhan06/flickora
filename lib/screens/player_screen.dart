import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../providers/watchlist_provider.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem media;
  final String initialVideoKey;

  const PlayerScreen({
    super.key,
    required this.media,
    required this.initialVideoKey,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.initialVideoKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        showLiveFullscreenButton: true,
        useHybridComposition: true,
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    if (_isPlayerReady && mounted) {
      final position = _controller.value.position.inSeconds;
      final total = _controller.metadata.duration.inSeconds;
      if (total > 0) {
        final progress = (position / total).clamp(0.0, 1.0);
        context.read<WatchlistProvider>().saveProgress(
          widget.media,
          progress,
          position,
          total,
        );
      }
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: FlickoraTheme.primaryRed,
        progressColors: const ProgressBarColors(
          playedColor: FlickoraTheme.primaryRed,
          handleColor: FlickoraTheme.accentRed,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white12,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.media.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FlickoraTheme.accentRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: FlickoraTheme.accentRed.withOpacity(0.4)),
                ),
                child: const Text(
                  '1080p Ultra HD',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlickoraTheme.accentRed),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.media.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: FlickoraTheme.goldAccent, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.media.formattedRating,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.media.releaseYear} • ${widget.media.formattedRuntime} • Zero In-App Ads',
                      style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: FlickoraTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: FlickoraTheme.accentRed, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Playing official HD stream with high-fidelity audio.',
                              style: TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
