import 'media_item.dart';

class CinematographyTechnique {
  final String id;
  final String name;
  final String alias;
  final String description;
  final String opticalPrinciple;
  final String directorExample;
  final String sceneDescription;
  final MediaItem media;

  CinematographyTechnique({
    required this.id,
    required this.name,
    required this.alias,
    required this.description,
    required this.opticalPrinciple,
    required this.directorExample,
    required this.sceneDescription,
    required this.media,
  });

  static List<CinematographyTechnique> getMasterTechniques() {
    return [
      CinematographyTechnique(
        id: 'dolly_zoom',
        name: 'The Dolly Zoom',
        alias: 'The "Vertigo" Effect / Trombone Shot',
        description: 'Simultaneously dollies the camera forward while zooming the lens out (or vice versa), keeping the subject the exact same size while warping the background perspective.',
        opticalPrinciple: 'Dynamically shifts focal length and camera distance in inverse unison to evoke disorientation or sudden dread.',
        directorExample: 'Alfred Hitchcock (Vertigo), Steven Spielberg (Jaws)',
        sceneDescription: 'Chief Brody sits on Amity Island beach when a shark attacks, background perspective suddenly hyper-stretches.',
        media: MediaItem(
          id: 578,
          title: 'Jaws',
          overview: 'When an insatiable great white shark terrorizes Amity Island, a police chief hunts it.',
          posterPath: '/lxM6kqbGpnVUSkJuSw8ofZpdap5.jpg',
          backdropPath: '/7xom5s1gG1wK8B1wM4gQ5pX0.jpg',
          voteAverage: 8.1,
          voteCount: 10000,
          releaseDate: '1975-06-20',
          genreIds: [28, 53, 12],
          mediaType: 'movie',
        ),
      ),
      CinematographyTechnique(
        id: 'long_take',
        name: 'The Unbroken Long Take',
        alias: 'The "Oner" Sequence',
        description: 'An extended, continuous camera movement spanning several minutes without a single visible editorial cut.',
        opticalPrinciple: 'Maintains temporal integrity, making audiences feel physically trapped alongside characters in real-time.',
        directorExample: 'Sam Mendes (1917), Alfonso Cuarón (Children of Men)',
        sceneDescription: 'Lance Corporal Schofield sprints horizontally through an active battlefield trench bombardment.',
        media: MediaItem(
          id: 530915,
          title: '1917',
          overview: 'At the height of the First World War, two young British soldiers are given an impossible mission.',
          posterPath: '/iZf0KyrE25z1sage4SYFLG6mb9Q.jpg',
          backdropPath: '/2W0nM3Z7oJ0X8cW3n6gK4v.jpg',
          voteAverage: 8.0,
          voteCount: 12000,
          releaseDate: '2019-12-25',
          genreIds: [10752, 18, 28],
          mediaType: 'movie',
        ),
      ),
      CinematographyTechnique(
        id: 'center_symmetry',
        name: 'Center-Weighted Symmetry',
        alias: 'One-Point Perspective',
        description: 'Framing all visual elements around a single mathematical center vanishing point, creating hypnotic aesthetic balance.',
        opticalPrinciple: 'Forces the human eye straight toward the exact center of the screen, creating uncanny or storybook harmony.',
        directorExample: 'Stanley Kubrick (The Shining), Wes Anderson (Grand Budapest Hotel)',
        sceneDescription: 'M. Gustave walks down the perfectly balanced, candy-hued hotel hallway.',
        media: MediaItem(
          id: 120467,
          title: 'The Grand Budapest Hotel',
          overview: 'Adventures of Gustave H, a legendary concierge at a famous European hotel.',
          posterPath: '/eWdyYQreja6JGCzqHWX9nz3UwNx.jpg',
          backdropPath: '/bB0K4Ue0xGkK28B101GZl5G9Qe0.jpg',
          voteAverage: 8.0,
          voteCount: 14000,
          releaseDate: '2014-02-26',
          genreIds: [35, 18],
          mediaType: 'movie',
        ),
      ),
      CinematographyTechnique(
        id: 'dutch_angle',
        name: 'The Dutch Angle',
        alias: 'The German Expressionist Tilt',
        description: 'The camera roll axis is tilted 15 to 45 degrees so that the horizon line is not parallel to the bottom of the frame.',
        opticalPrinciple: 'Subconsciously communicates psychological instability, paranoia, deception, or a world out of balance.',
        directorExample: 'Carol Reed (The Third Man), Christopher Nolan (Inception)',
        sceneDescription: 'Dream architectural physics fold Paris streets over on top of themselves.',
        media: MediaItem(
          id: 27205,
          title: 'Inception',
          overview: 'A thief who steals corporate secrets through dream-sharing technology.',
          posterPath: '/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
          backdropPath: '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
          voteAverage: 8.4,
          voteCount: 36000,
          releaseDate: '2010-07-15',
          genreIds: [28, 878, 12],
          mediaType: 'movie',
        ),
      ),
    ];
  }
}
