import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/actor.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loader.dart';

class ActorScreen extends StatefulWidget {
  final int actorId;
  final String initialName;
  final String? initialProfilePath;

  const ActorScreen({
    super.key,
    required this.actorId,
    required this.initialName,
    this.initialProfilePath,
  });

  @override
  State<ActorScreen> createState() => _ActorScreenState();
}

class _ActorScreenState extends State<ActorScreen> {
  ActorDetail? _actor;
  bool _isLoading = true;
  bool _isBioExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadActorData();
  }

  Future<void> _loadActorData() async {
    final service = context.read<TmdbService>();
    try {
      final data = await service.getActorDetails(widget.actorId);
      if (mounted) {
        setState(() {
          _actor = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _actor?.name ?? widget.initialName;
    final profileUrl = _actor?.profileUrl ??
        (widget.initialProfilePath != null
            ? 'https://image.tmdb.org/t/p/w500${widget.initialProfilePath}'
            : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80');

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: FlickoraTheme.bgDark,
            leading: IconButton(
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: profileUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    placeholder: (_, __) => Container(color: FlickoraTheme.bgCard),
                    errorWidget: (_, __, ___) => Container(color: FlickoraTheme.bgCardHighlight),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: FlickoraTheme.darkFadeGradient,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: FlickoraTheme.primaryRed.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: FlickoraTheme.primaryRed.withOpacity(0.6)),
                              ),
                              child: Text(
                                _actor?.knownForDepartment ?? 'Acting',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: FlickoraTheme.accentRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_actor?.placeOfBirth != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _actor!.placeOfBirth!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_actor?.birthday != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, size: 16, color: FlickoraTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Born: ${_actor!.birthday}',
                          style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Biography',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const ShimmerLoader(width: double.infinity, height: 70)
                  else ...[
                    GestureDetector(
                      onTap: () => setState(() => _isBioExpanded = !_isBioExpanded),
                      child: Text(
                        _actor?.biography ?? 'No biography available.',
                        maxLines: _isBioExpanded ? null : 4,
                        overflow: _isBioExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, height: 1.5, color: FlickoraTheme.textSecondary),
                      ),
                    ),
                    if ((_actor?.biography.length ?? 0) > 160) ...[
                      GestureDetector(
                        onTap: () => setState(() => _isBioExpanded = !_isBioExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isBioExpanded ? 'Show Less' : 'Read More',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: FlickoraTheme.accentRed,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: FlickoraTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filmography & Known For',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_isLoading)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 6,
                      itemBuilder: (_, __) => const ShimmerLoader(width: 100, height: 160),
                    )
                  else if (_actor != null && _actor!.filmography.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _actor!.filmography.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          media: _actor!.filmography[index],
                          width: double.infinity,
                          height: 155,
                        );
                      },
                    )
                  else
                    const Center(
                      child: Text('No titles listed', style: TextStyle(color: FlickoraTheme.textMuted)),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
