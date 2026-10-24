import 'media_item.dart';

class DirectorProfile {
  final String id;
  final String name;
  final String birthYear;
  final String nationality;
  final String portraitUrl;
  final String bio;
  final List<String> hallmarks;
  final List<String> famousQuotes;
  final List<MediaItem> filmography;

  DirectorProfile({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.nationality,
    required this.portraitUrl,
    required this.bio,
    required this.hallmarks,
    required this.famousQuotes,
    required this.filmography,
  });

  static List<DirectorProfile> getDirectors() {
    return [
      DirectorProfile(
        id: 'nolan',
        name: 'Christopher Nolan',
        birthYear: '1970',
        nationality: 'British-American',
        portraitUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
        bio: 'Renowned for mind-bending, non-linear narratives, practical in-camera visual effects, IMAX 70mm mastery, and sweeping Hans Zimmer / Ludwig Göransson orchestral scores.',
        hallmarks: [
          'Non-linear timeline cross-cutting',
          'Preference for practical stunts over CGI',
          'Large-format IMAX 70mm cameras',
          'Themes of obsession, grief, and subjective time',
        ],
        famousQuotes: [
          '"I have always believed that film is a medium best experienced in a giant theater."',
          '"Time is the most potent cinematic device we possess."',
        ],
        filmography: [
          MediaItem(
            id: 872585,
            title: 'Oppenheimer',
            overview: 'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb.',
            posterPath: '/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
            backdropPath: '/rM5Y09CghvQIA3ne2Y5EGaq3G8M.jpg',
            voteAverage: 8.1,
            voteCount: 9000,
            releaseDate: '2023-07-19',
            genreIds: [18, 36],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 157336,
            title: 'Interstellar',
            overview: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
            posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
            backdropPath: '/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
            voteAverage: 8.4,
            voteCount: 35000,
            releaseDate: '2014-11-05',
            genreIds: [12, 18, 878],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 27205,
            title: 'Inception',
            overview: 'A thief who steals corporate secrets through the use of dream-sharing technology.',
            posterPath: '/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
            backdropPath: '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
            voteAverage: 8.4,
            voteCount: 36000,
            releaseDate: '2010-07-15',
            genreIds: [28, 878, 12],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 155,
            title: 'The Dark Knight',
            overview: 'Batman raises the stakes in his war on crime with the help of Lt. Jim Gordon and Harvey Dent.',
            posterPath: '/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
            backdropPath: '/dqK9Hag1054tghRQSqLSfrkvQnA.jpg',
            voteAverage: 8.5,
            voteCount: 32000,
            releaseDate: '2008-07-16',
            genreIds: [18, 28, 80],
            mediaType: 'movie',
          ),
        ],
      ),
      DirectorProfile(
        id: 'villeneuve',
        name: 'Denis Villeneuve',
        birthYear: '1967',
        nationality: 'Canadian',
        portraitUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=80',
        bio: 'Master of atmosphere, patient tension, and monumental sci-fi worldbuilding. Collaborator with Roger Deakins and Greig Fraser.',
        hallmarks: [
          'Monolithic architecture & scale contrast',
          'Intense, rumbling bass sound design',
          'Deliberate, contemplative pacing',
          'Themes of language, destiny, and moral survival',
        ],
        famousQuotes: [
          '"Cinema is pure image and sound, the power of cinema is when you have no dialogue."',
        ],
        filmography: [
          MediaItem(
            id: 693134,
            title: 'Dune: Part Two',
            overview: 'Paul Atreides unites with Chani and the Fremen while seeking revenge.',
            posterPath: '/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
            backdropPath: '/xOMo8BRK7PfcJv9JCnx7s520DRq.jpg',
            voteAverage: 8.2,
            voteCount: 5000,
            releaseDate: '2024-02-27',
            genreIds: [878, 12],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 335984,
            title: 'Blade Runner 2049',
            overview: 'Young Blade Runner K unearths a long-buried secret.',
            posterPath: '/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
            backdropPath: '/ilRyASDvt7vCTRdtV9z7909A6n9.jpg',
            voteAverage: 7.6,
            voteCount: 13000,
            releaseDate: '2017-10-04',
            genreIds: [878, 18, 9648],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 329865,
            title: 'Arrival',
            overview: 'A linguist works with the military to communicate with alien lifeforms.',
            posterPath: '/x2FJsf1ElAgr63Y3PNPtJrcmpoe.jpg',
            backdropPath: '/yIZ1xendyQcxY3nGazoS29vgNZu.jpg',
            voteAverage: 7.6,
            voteCount: 17000,
            releaseDate: '2016-11-10',
            genreIds: [18, 878, 9648],
            mediaType: 'movie',
          ),
        ],
      ),
      DirectorProfile(
        id: 'miyazaki',
        name: 'Hayao Miyazaki',
        birthYear: '1941',
        nationality: 'Japanese',
        portraitUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=80',
        bio: 'Co-founder of Studio Ghibli and universal animation legend. Creator of soaring hand-drawn fantasy universes exploring humanity\'s harmony with nature.',
        hallmarks: [
          'Exquisite hand-drawn watercolored landscapes',
          'Themes of environmental balance and pacifism',
          'Iconic flying machines and soaring flight sequences',
          'Introspective "ma" (empty quiet moments between action)',
        ],
        famousQuotes: [
          '"The concept of portraying evil and then destroying it — I know this is considered mainstream, but I think it is rotten."',
        ],
        filmography: [
          MediaItem(
            id: 129,
            title: 'Spirited Away',
            overview: 'A 10-year-old girl wanders into a world ruled by gods, witches, and spirits.',
            posterPath: '/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
            backdropPath: '/Ab8mkHmkYADjU7wQiOkia9BzGvS.jpg',
            voteAverage: 8.5,
            voteCount: 16000,
            releaseDate: '2001-07-20',
            genreIds: [16, 14, 10751],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 4935,
            title: 'Howl\'s Moving Castle',
            overview: 'A cursed young woman finds shelter in the walking castle of a wizard.',
            posterPath: '/6pTqdt55k2lIuhP4pLq2YkKvh9R.jpg',
            backdropPath: '/7R6l31f1pM4y9B4oW9Q8ZgKj58o.jpg',
            voteAverage: 8.4,
            voteCount: 10000,
            releaseDate: '2004-11-20',
            genreIds: [14, 16, 12],
            mediaType: 'movie',
          ),
        ],
      ),
      DirectorProfile(
        id: 'tarantino',
        name: 'Quentin Tarantino',
        birthYear: '1963',
        nationality: 'American',
        portraitUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=500&auto=format&fit=crop&q=80',
        bio: 'Pioneered explosive hyper-literate dialogue, retro pop-culture soundtracks, stylized violence, and ensemble pulp homage.',
        hallmarks: [
          'Trunk POV camera shots',
          'Non-chronological chapter cards',
          'Extended, crackling dialogue standoff scenes',
          'Obscure 60s & 70s vinyl soundtrack curation',
        ],
        famousQuotes: [
          '"I steal from every movie ever made. Great artists steal; they don\'t do homages."',
        ],
        filmography: [
          MediaItem(
            id: 680,
            title: 'Pulp Fiction',
            overview: 'The lives of two mob hitmen, a boxer, and a pair of diner bandits intertwine.',
            posterPath: '/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
            backdropPath: '/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg',
            voteAverage: 8.5,
            voteCount: 27000,
            releaseDate: '1994-09-10',
            genreIds: [53, 80],
            mediaType: 'movie',
          ),
          MediaItem(
            id: 16869,
            title: 'Inglourious Basterds',
            overview: 'In Nazi-occupied France, a group of Jewish U.S. soldiers plan an assassination.',
            posterPath: '/7sfbEnaARXDD5Km0CZ7D7uc2hvY.jpg',
            backdropPath: '/8eihUxMZ0rbCuuv8h5Q066Qc5g0.jpg',
            voteAverage: 8.2,
            voteCount: 22000,
            releaseDate: '2009-08-19',
            genreIds: [18, 53, 10752],
            mediaType: 'movie',
          ),
        ],
      ),
    ];
  }
}
