import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../models/subtitle_cue.dart';
import '../models/scene_bookmark.dart';
import '../services/storage_service.dart';
import '../providers/watchlist_provider.dart';
import '../providers/settings_provider.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem media;
  final String? initialVideoKey;
  final String? directStreamUrl;
  final String? episodeTitle;
  final int? initialSeekSeconds;

  const PlayerScreen({
    super.key,
    required this.media,
    this.initialVideoKey,
    this.directStreamUrl,
    this.episodeTitle,
    this.initialSeekSeconds,
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

  bool _ambientGlowEnabled = true;
  Color _ambientColor = const Color(0xFFE50914);
  SubtitleTrack? _selectedSubtitleTrack;
  List<SubtitleTrack> _availableSubtitles = [];
  String? _currentSubtitleText;
  bool _dialogBoostEnabled = false;
  int _currentSourceIndex = 1;
  String _selectedAudioDub = 'Original Master (Dolby Atmos)';

  @override
  void initState() {
    super.initState();
    _availableSubtitles = SubtitleTrack.getMockTracksFor(widget.media.title);
    if (_availableSubtitles.isNotEmpty) {
      _selectedSubtitleTrack = _availableSubtitles.first;
    }
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
            if (widget.initialSeekSeconds != null) {
              _nativePlayerController!.seekTo(Duration(seconds: widget.initialSeekSeconds!));
            }
          }
        });

      _nativePlayerController!.addListener(_nativeListener);
    } else {
      _isUsingNativeStream = false;
      final videoKey = widget.initialVideoKey ?? widget.media.trailerKey ?? 'Way9Dexny3w';
      _youtubePlayerController?.dispose();
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoKey,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          showLiveFullscreenButton: true,
          useHybridComposition: true,
          startAt: widget.initialSeekSeconds ?? 0,
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
      _updateActiveSubtitle(pos);
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
      _updateActiveSubtitle(pos);
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

  void _updateActiveSubtitle(Duration pos) {
    if (_selectedSubtitleTrack == null) {
      if (_currentSubtitleText != null) setState(() => _currentSubtitleText = null);
      return;
    }
    final active = _selectedSubtitleTrack!.cues.where((c) => c.isActiveAt(pos)).firstOrNull;
    final newText = active?.text;
    if (newText != _currentSubtitleText) {
      setState(() => _currentSubtitleText = newText);
    }
  }

  void _showSubtitleSelectorDialog() {
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
                  Icon(Icons.subtitles_rounded, color: FlickoraTheme.accentRed, size: 22),
                  SizedBox(width: 10),
                  Text('Subtitle & Closed Captions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _selectedSubtitleTrack == null ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: _selectedSubtitleTrack == null ? FlickoraTheme.primaryRed : Colors.white54,
                ),
                title: const Text('Off (No Subtitles)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _selectedSubtitleTrack = null;
                    _currentSubtitleText = null;
                  });
                  Navigator.pop(ctx);
                },
              ),
              ..._availableSubtitles.map((track) {
                final isSel = _selectedSubtitleTrack?.id == track.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSel ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSel ? FlickoraTheme.primaryRed : Colors.white54,
                  ),
                  title: Text(track.languageName, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                  onTap: () {
                    setState(() => _selectedSubtitleTrack = track);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSourceSwitcherDialog() {
    final sources = [
      {'index': 1, 'name': 'Stream Source 1: 4K Ultra Master (CDN)', 'quality': '4K HDR'},
      {'index': 2, 'name': 'Stream Source 2: 1080p Fast Mirror', 'quality': '1080p'},
      {'index': 3, 'name': 'Stream Source 3: HLS Adaptive Multi-Bitrate', 'quality': 'Auto'},
      {'index': 4, 'name': 'Stream Source 4: Official Studio Trailer', 'quality': '1080p'},
    ];

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
                  Icon(Icons.layers_rounded, color: Colors.blueAccent, size: 22),
                  SizedBox(width: 10),
                  Text('Stream Source Fallback CDN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Switch streaming CDN servers if encountering network latency', style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted)),
              const SizedBox(height: 14),
              ...sources.map((src) {
                final idx = src['index'] as int;
                final isCurrent = _currentSourceIndex == idx;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isCurrent ? FlickoraTheme.primaryRed : Colors.white54,
                  ),
                  title: Text(src['name'] as String, style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white70, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                    child: Text(src['quality'] as String, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ),
                  onTap: () {
                    setState(() => _currentSourceIndex = idx);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Switched to ${src['name']}'), duration: const Duration(seconds: 1)),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSoundLabDialog() {
    final settings = context.read<SettingsProvider>();
    final profiles = [
      {'name': 'Dialogue Clarity Boost', 'desc': 'Equalizes 1-3 kHz voice bands for crisp speech over explosions', 'icon': Icons.record_voice_over_rounded},
      {'name': 'Midnight Compression', 'desc': 'Dynamically controls spikes for late-night viewing without waking others', 'icon': Icons.nightlife_rounded},
      {'name': 'IMAX Deep Bass', 'desc': 'Deep rumble & punchy low-frequency cinema impact for headphones', 'icon': Icons.speaker_group_rounded},
      {'name': 'Acoustic Score Mode', 'desc': 'Lush wide stereo separation for orchestral scores and soundtrack lovers', 'icon': Icons.music_note_rounded},
      {'name': 'Studio Neutral', 'desc': 'Uncolored, pure flat direct monitor mix as mixed by sound engineers', 'icon': Icons.equalizer_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: FlickoraTheme.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.graphic_eq_rounded, color: Colors.cyanAccent, size: 22),
                  SizedBox(width: 10),
                  Text('Cinema Sound Lab & EQ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Acoustic DSP mastering profiles tailored for headphone and speaker acoustics', style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted)),
              const SizedBox(height: 14),
              ...profiles.map((p) {
                final isCurrent = settings.audioProfile == p['name'];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(p['icon'] as IconData, color: isCurrent ? Colors.cyanAccent : Colors.white54),
                  title: Text(p['name'] as String, style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white70, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  subtitle: Text(p['desc'] as String, style: const TextStyle(fontSize: 10, color: FlickoraTheme.textMuted)),
                  trailing: isCurrent ? const Icon(Icons.check, color: Colors.cyanAccent, size: 18) : null,
                  onTap: () {
                    settings.setAudioProfile(p['name'] as String);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Audio Profile: ${p['name']} Active'), duration: const Duration(seconds: 1)),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddBookmarkDialog() {
    final currentSec = _currentPosition.inSeconds;
    final timecode = _formatDuration(_currentPosition);
    final controller = TextEditingController(text: 'Scene note at $timecode');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: FlickoraTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.bookmark_add_outlined, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text('Bookmark Scene ($timecode)', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a personal note or quote for this moment in the film:', style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter scene quote or description...',
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: FlickoraTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final note = controller.text.trim();
                final bookmark = SceneBookmark(
                  id: 'bm_${DateTime.now().millisecondsSinceEpoch}',
                  mediaId: widget.media.id,
                  mediaTitle: widget.media.title,
                  posterPath: widget.media.posterPath,
                  seconds: currentSec,
                  note: note.isNotEmpty ? note : 'Bookmarked scene at $timecode',
                  createdAt: DateTime.now(),
                );
                await StorageService().saveSceneBookmark(bookmark);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scene bookmarked at $timecode! Saved.'), backgroundColor: FlickoraTheme.accentRed),
                  );
                }
              },
              child: const Text('Save Bookmark'),
            ),
          ],
        );
      },
    );
  }

  void _showAudioDubDialog() {
    final dubs = [
      {'name': 'Original Master Audio', 'format': 'Dolby Atmos / TrueHD 7.1'},
      {'name': 'English Dub', 'format': 'Dolby Digital 5.1 (384 kbps)'},
      {'name': 'Spanish (Latinoamérica)', 'format': 'Stereo 2.0 (192 kbps)'},
      {'name': 'French (V.F.)', 'format': 'Stereo 2.0 (192 kbps)'},
      {'name': 'Japanese Audio', 'format': 'DTS-HD Master 5.1'},
      {'name': 'German Dub', 'format': 'Dolby Digital 5.1'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: FlickoraTheme.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.audiotrack_rounded, color: Colors.greenAccent, size: 22),
                  SizedBox(width: 10),
                  Text('Audio Dub & Spoken Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Select original voice track or localized foreign dubbing', style: TextStyle(fontSize: 12, color: FlickoraTheme.textMuted)),
              const SizedBox(height: 14),
              ...dubs.map((d) {
                final isCurrent = _selectedAudioDub.startsWith(d['name']!.split(' ').first);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: isCurrent ? Colors.greenAccent : Colors.white54),
                  title: Text(d['name']!, style: TextStyle(fontSize: 13, color: isCurrent ? Colors.white : Colors.white70, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                    child: Text(d['format']!, style: const TextStyle(fontSize: 9.5, color: Colors.white70)),
                  ),
                  onTap: () {
                    setState(() => _selectedAudioDub = d['name']!);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Audio Dub Switched: ${d['name']}'), duration: const Duration(seconds: 1)),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
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
              // Cinema Ambient Glow (Ambilight Halo)
              if (_ambientGlowEnabled)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 240,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: _ambientColor.withOpacity(0.4),
                          blurRadius: 90,
                          spreadRadius: 25,
                        ),
                      ],
                    ),
                  ),
                ),

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

              // Live On-Screen Subtitle Rendering
              if (_currentSubtitleText != null && _currentSubtitleText!.isNotEmpty)
                Positioned(
                  bottom: _showControls ? 84 : 28,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        _currentSubtitleText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
                        ),
                      ),
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
                        // Binge Next Episode Banner
                        if (_totalDuration.inSeconds > 60 && (_totalDuration - _currentPosition).inSeconds <= 25)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: FlickoraTheme.bgSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: FlickoraTheme.accentRed),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.skip_next_rounded, color: FlickoraTheme.accentRed, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Next Episode in ${(_totalDuration - _currentPosition).inSeconds}s...',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _seekRelative(30);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Starting Next Episode...'), duration: Duration(seconds: 1)),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: FlickoraTheme.primaryRed, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('Play Next Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                                const SizedBox(width: 8),

                                // Subtitles toggle
                                GestureDetector(
                                  onTap: _showSubtitleSelectorDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _selectedSubtitleTrack != null ? FlickoraTheme.primaryRed : Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.subtitles_rounded, color: Colors.white, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedSubtitleTrack != null ? _selectedSubtitleTrack!.languageCode.toUpperCase() : 'CC',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Source CDN switcher
                                GestureDetector(
                                  onTap: _showSourceSwitcherDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.layers_rounded, color: Colors.blueAccent, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          'S$_currentSourceIndex',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Sound Lab EQ Profile
                                GestureDetector(
                                  onTap: _showSoundLabDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.graphic_eq_rounded, color: Colors.cyanAccent, size: 14),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Bookmark Scene
                                GestureDetector(
                                  onTap: _showAddBookmarkDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.bookmark_add_outlined, color: Colors.amber, size: 14),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Audio Dub Language Switcher
                                GestureDetector(
                                  onTap: _showAudioDubDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.audiotrack_rounded, color: Colors.greenAccent, size: 14),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Skip Intro Button (+85s)
                                GestureDetector(
                                  onTap: () => _seekRelative(85),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Skip Intro', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Ambient Glow toggle
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _ambientGlowEnabled = !_ambientGlowEnabled);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_ambientGlowEnabled ? 'Cinema Ambilight Glow: ON' : 'Cinema Ambilight Glow: OFF'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _ambientGlowEnabled ? const Color(0x33E50914) : Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: _ambientGlowEnabled ? FlickoraTheme.accentRed : Colors.transparent),
                                    ),
                                    child: const Icon(Icons.wb_incandescent_outlined, color: Colors.white, size: 14),
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
