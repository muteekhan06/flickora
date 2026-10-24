import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/media_item.dart';
import '../screens/detail_screen.dart';
import 'custom_badge.dart';

class MovieCard extends StatelessWidget {
  final MediaItem media;
  final double width;
  final double height;
  final bool showRating;
  final bool showTitle;

  const MovieCard({
    super.key,
    required this.media,
    this.width = 135,
    this.height = 200,
    this.showRating = true,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(media: media),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Hero(
                    tag: 'poster_${media.id}_${media.mediaType}',
                    child: CachedNetworkImage(
                      imageUrl: media.posterUrl,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: width,
                        height: height,
                        color: FlickoraTheme.bgCard,
                        child: const Center(
                          child: Icon(Icons.movie_outlined, color: Colors.white24, size: 32),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: width,
                        height: height,
                        color: FlickoraTheme.bgCardHighlight,
                        child: const Icon(Icons.broken_image_outlined, color: Colors.white30, size: 32),
                      ),
                    ),
                  ),

                  // Rating Badge
                  if (showRating)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CustomBadge.rating(media.formattedRating),
                    ),

                  // 4K Ultra HD badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: CustomBadge.quality(media.voteAverage >= 8.0 ? '4K UHD' : 'HD'),
                  ),
                ],
              ),
            ),
            if (showTitle) ...[
              const SizedBox(height: 8),
              Text(
                media.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FlickoraTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    media.releaseYear,
                    style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: FlickoraTheme.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      media.genreNames.isNotEmpty ? media.genreNames.first : 'Cinema',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
