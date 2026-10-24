import 'media_item.dart';

class FestivalAward {
  final String id;
  final String festivalName;
  final String awardName;
  final String year;
  final String trophyIcon;
  final String juryPresident;
  final String citation;
  final MediaItem media;

  FestivalAward({
    required this.id,
    required this.festivalName,
    required this.awardName,
    required this.year,
    required this.trophyIcon,
    required this.juryPresident,
    required this.citation,
    required this.media,
  });

  static List<FestivalAward> getFestivalVault() {
    return [
      FestivalAward(
        id: 'cannes_parasite',
        festivalName: 'Cannes Film Festival',
        awardName: 'Palme d\'Or (Unanimous)',
        year: '2019',
        trophyIcon: '🌿',
        juryPresident: 'Alejandro González Iñárritu',
        citation: 'For masterfully weaving biting social class satire with relentless thriller mechanics.',
        media: MediaItem(
          id: 496243,
          title: 'Parasite',
          overview: 'All unemployed, Ki-taek\'s family takes peculiar interest in the wealthy Parks.',
          posterPath: '/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
          backdropPath: '/hiKmpZMGZsrkA3cdce8a7Dpos1j.jpg',
          voteAverage: 8.5,
          voteCount: 17000,
          releaseDate: '2019-05-30',
          genreIds: [35, 53, 18],
          mediaType: 'movie',
        ),
      ),
      FestivalAward(
        id: 'cannes_pulp',
        festivalName: 'Cannes Film Festival',
        awardName: 'Palme d\'Or',
        year: '1994',
        trophyIcon: '🌿',
        juryPresident: 'Clint Eastwood',
        citation: 'A revolutionary post-modern masterpiece that redefined narrative cinema for a generation.',
        media: MediaItem(
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
      ),
      FestivalAward(
        id: 'venice_joker',
        festivalName: 'Venice International Film Festival',
        awardName: 'Golden Lion (Leone d\'Oro)',
        year: '2019',
        trophyIcon: '🦁',
        juryPresident: 'Lucrecia Martel',
        citation: 'An uncompromising character study exploring isolation, mental illness, and societal decay.',
        media: MediaItem(
          id: 475557,
          title: 'Joker',
          overview: 'During the 1980s, a failed stand-up comedian is driven to insanity in Gotham City.',
          posterPath: '/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
          backdropPath: '/n6bUvigpRFqSwmPp1m2YADdbRBc.jpg',
          voteAverage: 8.2,
          voteCount: 24000,
          releaseDate: '2019-10-02',
          genreIds: [80, 53, 18],
          mediaType: 'movie',
        ),
      ),
      FestivalAward(
        id: 'berlin_spirited',
        festivalName: 'Berlin International Film Festival',
        awardName: 'Golden Bear (Goldener Bär)',
        year: '2002',
        trophyIcon: '🐻',
        juryPresident: 'Mira Nair',
        citation: 'The only hand-drawn animated masterwork to ever claim the Golden Bear in Berlinale history.',
        media: MediaItem(
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
      ),
      FestivalAward(
        id: 'cannes_anatomy',
        festivalName: 'Cannes Film Festival',
        awardName: 'Palme d\'Or',
        year: '2023',
        trophyIcon: '🌿',
        juryPresident: 'Ruben Östlund',
        citation: 'A surgical dissection of a marriage, truth, and judicial ambiguity in the French Alps.',
        media: MediaItem(
          id: 915935,
          title: 'Anatomy of a Fall',
          overview: 'A woman is suspected of her husband\'s murder, and their blind son faces a moral dilemma.',
          posterPath: '/kQs6keheMwCxJxrzVHY5xYsRbgK.jpg',
          backdropPath: '/jXJxMcikB5Z8iB7b6Tf1HqD9p1P.jpg',
          voteAverage: 7.7,
          voteCount: 2000,
          releaseDate: '2023-08-23',
          genreIds: [18, 9648, 80],
          mediaType: 'movie',
        ),
      ),
    ];
  }
}
