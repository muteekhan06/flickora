import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/cinematography_technique.dart';
import 'player_screen.dart';

class CinematographyLabScreen extends StatefulWidget {
  const CinematographyLabScreen({super.key});

  @override
  State<CinematographyLabScreen> createState() => _CinematographyLabScreenState();
}

class _CinematographyLabScreenState extends State<CinematographyLabScreen> {
  final List<CinematographyTechnique> _techniques = CinematographyTechnique.getMasterTechniques();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Cinematography Framing Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF132832), FlickoraTheme.bgCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.camera_rounded, color: Colors.cyanAccent, size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visual Composition Masterclass',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Learn the optical principles and emotional psychology behind legendary cinematic camera movements.',
                        style: TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Techniques List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _techniques.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final tech = _techniques[index];
              return Container(
                decoration: BoxDecoration(
                  color: FlickoraTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backdrop with Title Overlay
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: tech.media.backdropUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                            ),
                            child: Text(
                              'Technique #${index + 1}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tech.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(tech.alias, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tech.description,
                            style: const TextStyle(fontSize: 12.5, color: Colors.white, height: 1.4),
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FlickoraTheme.bgSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Optical & Psychological Effect:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                const SizedBox(height: 4),
                                Text(tech.opticalPrinciple, style: const TextStyle(fontSize: 11.5, color: FlickoraTheme.textSecondary, height: 1.3)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.movie_creation_outlined, size: 14, color: FlickoraTheme.accentRed),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text('Master Practitioners: ${tech.directorExample}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Iconic Scene: ${tech.sceneDescription}', style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted)),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      media: tech.media,
                                      initialVideoKey: tech.media.trailerKey ?? 'Way9Dexny3w',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow_rounded, size: 20),
                              label: Text('Study Scene: ${tech.media.title}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
