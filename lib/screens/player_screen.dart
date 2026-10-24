import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../providers/watchlist_provider.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem media;
  final String? initialVideoKey;
  final String? directStreamUrl;
  final String? episodeTitle;

  const PlayerScreen({
    super.key,
    required this.media,
    this.initialVideoKey,
    this.directStreamUrl,
    this.episodeTitle,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // Engines
  VideoPlayerController? _nativePlayerController;
  YoutubePlayerController? _youtubePlayerController;

  bool _isUsingNativeStream = false;
  bool _isPlaying = false;
  bool _showControls = true;
  double _volume = 1.0;
  double _brightness = 0.5;
  bool _isDraggingBrightness = false;
  bool _isDraggingVolume = false;
  double _playbackSpeed = 1.0;
  BoxFit _aspectRatioFit = BoxFit.contain;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Timer? _sleepTimer;
  int? _sleepTimerMinutes;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer([String? customUrl]) {
    final streamUrl = customUrl ?? widget.directStreamUrl ?? widget.media.directStreamUrl;

    if (streamUrl != null && streamUrl.isNotEmpty) {
      _isUsingNativeStream = true;
      _nativePlayerController?.dispose();
      _nativePlayerController = VideoPlayerController.networkUrl(Uri.parse(streamUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _totalDuration = _nativePlayerController!.value.duration;
              _isPlaying = true;
            });
            _nativePlayerController!.play();
          }
        });

      _nativePlayerController!.addListener(_nativeListener);
    } else {
      _isUsingNativeStream = false;
      final videoKey = widget.initialVideoKey ?? widget.media.trailerKey ?? 'Way9Dexny3w';
      _youtubePlayerController?.dispose();
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoKey,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          showLiveFullscreenButton: true,
          useHybridComposition: true,
        ),
      )..addListener(_youtubeListener);
    }
  }

  void _nativeListener() {
    if (_nativePlayerController != null && mounted) {
      final pos = _nativePlayerController!.value.position;
      final total = _nativePlayerController!.value.duration;
      setState(() {
        _currentPosition = pos;
        _totalDuration = total;
        _isPlaying = _nativePlayerController!.value.isPlaying;
      });

      if (total.inSeconds > 0) {
        final progress = (pos.inSeconds / total.inSeconds).clamp(0.0, 1.0);
        context.read<WatchlistProvider>().saveProgress(
              widget.media,
              progress,
              pos.inSeconds,
              total.inSeconds,
            );
      }
    }
  }

  void _youtubeListener() {
    if (_youtubePlayerController != null && mounted) {
      final pos = _youtubePlayerController!.value.position;
      final total = _youtubePlayerController!.metadata.duration;
      if (total.inSeconds > 0) {
        final progress = (pos.inSeconds / total.inSeconds).clamp(0.0, 1.0);
        context.read<WatchlistProvider>().saveProgress(
              widget.media,
              progress,
              pos.inSeconds,
              total.inSeconds,
            );
      }
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _nativePlayerController?.removeListener(_nativeListener);
    _nativePlayerController?.dispose();
    _youtubePlayerController?.removeListener(_youtubeListener);
    _youtubePlayerController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _showSleepTimerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: FlickoraTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bedtime_rounded, color: Colors.amber, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Cinema Sleep Timer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _sleepTimerMinutes != null
                    ? 'Timer actively set for $_sleepTimerMinutes minutes'
                    : 'Automatically pause playback when you drift off to sleep',
                style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
              ),
              const SizedBox(height: 16),
              ...[15, 30, 45, 60].map((mins) {
                final isCurrent = _sleepTimerMinutes == mins;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isCurrent ? FlickoraTheme.primaryRed : Colors.white54,
                  ),
                  title: Text(
                    '$mins Minutes',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.white70,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _setSleepTimer(mins);
                    Navigator.pop(ctx);
                  },
                );
              }),
              if (_sleepTimerMinutes != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                  title: const Text('Cancel Sleep Timer', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    _cancelSleepTimer();
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() => _sleepTimerMinutes = minutes);
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      if (mounted) {
        if (_isUsingNativeStream && _nativePlayerController != null) {
          _nativePlayerController!.pause();
        } else if (_youtubePlayerController != null) {
          _youtubePlayerController!.pause();
        }
        setState(() {
          _isPlaying = false;
          _sleepTimerMinutes = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cinema Sleep Timer elapsed. Playback paused.'),
            backgroundColor: FlickoraTheme.bgCardHighlight,
          ),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sleep Timer set for $minutes minutes'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    setState(() => _sleepTimerMinutes = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep Timer cancelled'), duration: Duration(seconds: 1)),
    );
  }

  void _togglePlayPause() {
    if (_isUsingNativeStream && _nativePlayerController != null) {
      if (_nativePlayerController!.value.isPlaying) {
        _nativePlayerController!.pause();
      } else {
        _nativePlayerController!.play();
      }
      setState(() {
        _isPlaying = _nativePlayerController!.value.isPlaying;
      });
    }
  }

  void _seekRelative(int seconds) {
    if (_isUsingNativeStream && _nativePlayerController != null) {
      final newPos = _currentPosition + Duration(seconds: seconds);
      _nativePlayerController!.seekTo(newPos);
    }
  }

  void _cycleSpeed() {
    final speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final nextSpeed = speeds[nextIndex];
    setState(() => _playbackSpeed = nextSpeed);
    _nativePlayerController?.setPlaybackSpeed(nextSpeed);
    _youtubePlayerController?.setPlaybackRate(nextSpeed);
  }

  void _cycleAspectRatio() {
    setState(() {
      if (_aspectRatioFit == BoxFit.contain) {
        _aspectRatioFit = BoxFit.cover; // Zoom/Fill
      } else if (_aspectRatioFit == BoxFit.cover) {
        _aspectRatioFit = BoxFit.fill; // Stretch
      } else {
        _aspectRatioFit = BoxFit.contain; // Fit
      }
    });
  }

  void _showStreamUrlDialog() {
    final controller = TextEditingController(text: widget.media.directStreamUrl ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FlickoraTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Direct Stream URL', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter direct .mp4, .m3u8 (HLS), or web stream URL for this movie:',
                style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://.../video.mp4',
                  hintStyle: const TextStyle(color: FlickoraTheme.textMuted),
                  filled: true,
                  fillColor: FlickoraTheme.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: FlickoraTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (controller.text.trim().isNotEmpty) {
                  _initializePlayer(controller.text.trim());
                }
              },
              child: const Text('Stream Now'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    final secs = d.inSeconds % 60;
    final minStr = mins.toString().padLeft(2, '0');
    final secStr = secs.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minStr:$secStr';
    }
    return '$minStr:$secStr';
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = widget.episodeTitle != null
        ? '${widget.media.title} - ${widget.episodeTitle}'
        : widget.media.title;

    if (!_isUsingNativeStream && _youtubePlayerController != null) {
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
          controller: _youtubePlayerController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: FlickoraTheme.primaryRed,
          progressColors: const ProgressBarColors(
            playedColor: FlickoraTheme.primaryRed,
            handleColor: FlickoraTheme.accentRed,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white12,
          ),
        ),
        builder: (context, player) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text(displayTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.link_rounded, color: Colors.white),
                  tooltip: 'Play from URL',
                  onPressed: _showStreamUrlDialog,
                ),
              ],
            ),
            body: Column(
              children: [
                player,
                _buildPlaybackInfoBar(),
              ],
            ),
          );
        },
      );
    }

    // Native Video Player UI (.mp4 & .m3u8) with gestures
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          onDoubleTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < screenWidth / 2) {
              _seekRelative(-10);
            } else {
              _seekRelative(10);
            }
          },
          onVerticalDragUpdate: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final delta = -details.primaryDelta! / 200.0;
            if (details.localPosition.dx < screenWidth / 2) {
              setState(() {
                _brightness = (_brightness + delta).clamp(0.0, 1.0);
                _isDraggingBrightness = true;
                _isDraggingVolume = false;
              });
            } else {
              setState(() {
                _volume = (_volume + delta).clamp(0.0, 1.0);
                _isDraggingVolume = true;
                _isDraggingBrightness = false;
              });
              _nativePlayerController?.setVolume(_volume);
            }
          },
          onVerticalDragEnd: (_) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _isDraggingBrightness = false;
                  _isDraggingVolume = false;
                });
              }
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video Surface
              Center(
                child: _nativePlayerController != null && _nativePlayerController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _nativePlayerController!.value.aspectRatio,
                        child: FittedBox(
                          fit: _aspectRatioFit,
                          child: SizedBox(
                            width: _nativePlayerController!.value.size.width,
                            height: _nativePlayerController!.value.size.height,
                            child: VideoPlayer(_nativePlayerController!),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(color: FlickoraTheme.primaryRed),
              ),

              // Volume / Brightness overlay indicators
              if (_isDraggingBrightness)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.brightness_6_rounded, color: FlickoraTheme.goldAccent, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '${(_brightness * 100).toInt()}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_isDraggingVolume)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _volume > 0.5
                              ? Icons.volume_up_rounded
                              : _volume > 0
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_off_rounded,
                          color: FlickoraTheme.accentRed,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(_volume * 100).toInt()}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              // Controls Overlay
              if (_showControls) ...[
                // Top controls bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _sleepTimerMinutes != null ? Icons.bedtime_rounded : Icons.bedtime_outlined,
                            color: _sleepTimerMinutes != null ? Colors.amber : Colors.white,
                          ),
                          tooltip: 'Sleep Timer',
                          onPressed: _showSleepTimerDialog,
                        ),
                        IconButton(
                          icon: const Icon(Icons.link_rounded, color: Colors.white),
                          tooltip: 'Stream URL',
                          onPressed: _showStreamUrlDialog,
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Play / Pause and seek buttons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 42,
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                        onPressed: () => _seekRelative(-10),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: FlickoraTheme.primaryRed,
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        iconSize: 42,
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                        onPressed: () => _seekRelative(10),
                      ),
                    ],
                  ),
                ),

                // Bottom scrubber and speed / aspect buttons
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: FlickoraTheme.primaryRed,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: FlickoraTheme.accentRed,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: _totalDuration.inMilliseconds > 0
                                ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                                : 0.0,
                            onChanged: (val) {
                              final target = Duration(milliseconds: (val * _totalDuration.inMilliseconds).toInt());
                              _nativePlayerController?.seekTo(target);
                            },
                          ),
                        ),

                        // Time & controls row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                            Row(
                              children: [
                                // Speed button
                                GestureDetector(
                                  onTap: _cycleSpeed,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_playbackSpeed}x',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Aspect ratio toggle
                                GestureDetector(
                                  onTap: _cycleAspectRatio,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _aspectRatioFit == BoxFit.contain
                                          ? 'Fit'
                                          : _aspectRatioFit == BoxFit.cover
                                              ? 'Zoom'
                                              : '16:9',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackInfoBar() {
    return Padding(
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FlickoraTheme.accentRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: FlickoraTheme.accentRed.withOpacity(0.5)),
                ),
                child: const Text('1080p Ultra HD', style: TextStyle(fontSize: 10, color: FlickoraTheme.accentRed, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.media.releaseYear} • ${widget.media.formattedRuntime} • Zero In-App Ads',
            style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
