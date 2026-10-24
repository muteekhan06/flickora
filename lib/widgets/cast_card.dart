import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/cast.dart';
import '../screens/actor_screen.dart';

class CastCard extends StatelessWidget {
  final CastMember cast;

  const CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActorScreen(
              actorId: cast.id,
              initialName: cast.name,
              initialProfilePath: cast.profilePath,
            ),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: CachedNetworkImage(
                imageUrl: cast.profileUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: FlickoraTheme.bgCard,
                  child: const Icon(Icons.person, color: Colors.white24),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: FlickoraTheme.bgCardHighlight,
                  child: const Icon(Icons.person, color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cast.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FlickoraTheme.textPrimary,
              ),
            ),
            if (cast.character.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                cast.character,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: FlickoraTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
