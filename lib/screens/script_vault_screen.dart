import 'package:flutter/material.dart';
import '../core/theme.dart';

class ScriptExcerpt {
  final String title;
  final String writers;
  final String sceneHeading;
  final String actionDescription;
  final String character;
  final String dialogue;
  final String directorNote;

  ScriptExcerpt({
    required this.title,
    required this.writers,
    required this.sceneHeading,
    required this.actionDescription,
    required this.character,
    required this.dialogue,
    required this.directorNote,
  });
}

class ScriptVaultScreen extends StatefulWidget {
  const ScriptVaultScreen({super.key});

  @override
  State<ScriptVaultScreen> createState() => _ScriptVaultScreenState();
}

class _ScriptVaultScreenState extends State<ScriptVaultScreen> {
  final List<ScriptExcerpt> _scripts = [
    ScriptExcerpt(
      title: 'Interstellar',
      writers: 'Jonathan Nolan & Christopher Nolan',
      sceneHeading: 'EXT. ENDURANCE - DEEP SPACE',
      actionDescription: 'The module spins dangerously fast. 67, 68 RPM. Centrifugal gravity tears at the airframe. The docking ring looms closer, misaligned by degrees.',
      character: 'COOPER',
      dialogue: 'Case, get ready to match our spin with the retro thrusters. It\'s not possible? No... it\'s necessary.',
      directorNote: 'Nolan instructed Hans Zimmer to compose the pipe organ track "No Time For Caution" with 1 beat per second to mimic an unstoppable cosmic clock.',
    ),
    ScriptExcerpt(
      title: 'The Dark Knight',
      writers: 'Jonathan Nolan & Christopher Nolan (Story by David S. Goyer)',
      sceneHeading: 'INT. INTERROGATION ROOM - GOTHAM CENTRAL - NIGHT',
      actionDescription: 'Batman slams the Joker\'s face into the metal table. The Joker does not flinch. He laughs — a low, wheezing, breathless cackle of genuine amusement.',
      character: 'THE JOKER',
      dialogue: 'Don\'t talk like one of them. You\'re not! Even if you\'d like to be. To them, you\'re just a freak, like me! They need you right now, but when they don\'t, they\'ll cast you out like a leper!',
      directorNote: 'Heath Ledger asked Christian Bale to actually strike him with full force to heighten the visceral authenticity of the psychological duel.',
    ),
    ScriptExcerpt(
      title: 'Pulp Fiction',
      writers: 'Quentin Tarantino (Stories by Roger Avary)',
      sceneHeading: 'INT. '68 CHEVY CHEVELLE (MOVING) - MORNING',
      actionDescription: 'JULES is behind the wheel. VINCENT rides shotgun. They cruise down the sunny morning Los Angeles streets dressed in cheap dark suits.',
      character: 'VINCENT',
      dialogue: 'And you know what they call a Quarter Pounder with Cheese in Paris? They call it a Royale with Cheese.',
      directorNote: 'Tarantino designed mundane dialogue to precede horrific criminal violence, anchoring cinematic realism into pop-culture Americana.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Screenplay & Script Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1B1F2A), FlickoraTheme.bgCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: const [
                Icon(Icons.description_outlined, color: Colors.amberAccent, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Original Production Drafts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Examine formatted screenplay drafts and directorial annotations side-by-side with final cut performances.', style: TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Script Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _scripts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final s = _scripts[index];
              return Container(
                decoration: BoxDecoration(
                  color: FlickoraTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Production Draft', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Written by ${s.writers}', style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted)),
                    const SizedBox(height: 14),

                    // Courier New Script Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0F14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.sceneHeading, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                          const SizedBox(height: 8),
                          Text(s.actionDescription, style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white70, height: 1.4)),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(s.character, style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(s.dialogue, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white, height: 1.35)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: FlickoraTheme.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.amberAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s.directorNote, style: const TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary, height: 1.3)),
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
