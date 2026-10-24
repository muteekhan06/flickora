class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
  });

  bool isActiveAt(Duration position) {
    return position >= start && position <= end;
  }
}

class SubtitleTrack {
  final String id;
  final String languageName;
  final String languageCode;
  final List<SubtitleCue> cues;

  SubtitleTrack({
    required this.id,
    required this.languageName,
    required this.languageCode,
    required this.cues,
  });

  static List<SubtitleTrack> getMockTracksFor(String title) {
    return [
      SubtitleTrack(
        id: 'en',
        languageName: 'English [CC]',
        languageCode: 'en',
        cues: [
          SubtitleCue(start: const Duration(seconds: 2), end: const Duration(seconds: 6), text: '[Epic cinematic score swells]'),
          SubtitleCue(start: const Duration(seconds: 7), end: const Duration(seconds: 12), text: 'In a world where cinema defines reality...'),
          SubtitleCue(start: const Duration(seconds: 13), end: const Duration(seconds: 18), text: 'Every frame holds a mystery waiting to be unlocked.'),
          SubtitleCue(start: const Duration(seconds: 20), end: const Duration(seconds: 25), text: 'Hold your breath. The climax approaches.'),
          SubtitleCue(start: const Duration(seconds: 27), end: const Duration(seconds: 34), text: '[Dramatic orchestral crescendo]'),
          SubtitleCue(start: const Duration(seconds: 36), end: const Duration(seconds: 45), text: 'Nothing can prepare you for what lies ahead.'),
        ],
      ),
      SubtitleTrack(
        id: 'es',
        languageName: 'Español',
        languageCode: 'es',
        cues: [
          SubtitleCue(start: const Duration(seconds: 2), end: const Duration(seconds: 6), text: '[Música cinematográfica épica]'),
          SubtitleCue(start: const Duration(seconds: 7), end: const Duration(seconds: 12), text: 'En un mundo donde el cine define la realidad...'),
          SubtitleCue(start: const Duration(seconds: 13), end: const Duration(seconds: 18), text: 'Cada fotograma guarda un misterio.'),
          SubtitleCue(start: const Duration(seconds: 20), end: const Duration(seconds: 25), text: 'Contén la respiración. Se acerca el clímax.'),
          SubtitleCue(start: const Duration(seconds: 27), end: const Duration(seconds: 34), text: '[Crescendo orquestal dramático]'),
        ],
      ),
      SubtitleTrack(
        id: 'fr',
        languageName: 'Français',
        languageCode: 'fr',
        cues: [
          SubtitleCue(start: const Duration(seconds: 2), end: const Duration(seconds: 6), text: '[Musique symphonique grandiose]'),
          SubtitleCue(start: const Duration(seconds: 7), end: const Duration(seconds: 12), text: 'Dans un monde où le cinéma façonne le destin...'),
          SubtitleCue(start: const Duration(seconds: 13), end: const Duration(seconds: 18), text: 'Chaque plan recèle un mystère inoubliable.'),
        ],
      ),
    ];
  }
}
