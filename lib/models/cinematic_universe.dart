import 'media_item.dart';

class UniverseEntry {
  final MediaItem media;
  final int releaseIndex;
  final int chronologicalIndex;
  final String timelineEra;
  final String synopsisSnippet;

  UniverseEntry({
    required this.media,
    required this.releaseIndex,
    required this.chronologicalIndex,
    required this.timelineEra,
    required this.synopsisSnippet,
  });
}

class CinematicUniverse {
  final String id;
  final String title;
  final String tagline;
  final String bannerUrl;
  final String icon;
  final String description;
  final List<UniverseEntry> entries;

  CinematicUniverse({
    required this.id,
    required this.title,
    required this.tagline,
    required this.bannerUrl,
    required this.icon,
    required this.description,
    required this.entries,
  });

  List<UniverseEntry> get inReleaseOrder {
    final list = List<UniverseEntry>.from(entries);
    list.sort((a, b) => a.releaseIndex.compareTo(b.releaseIndex));
    return list;
  }

  List<UniverseEntry> get inChronologicalOrder {
    final list = List<UniverseEntry>.from(entries);
    list.sort((a, b) => a.chronologicalIndex.compareTo(b.chronologicalIndex));
    return list;
  }

  static List<CinematicUniverse> getUniverses() {
    return [
      CinematicUniverse(
        id: 'marvel',
        title: 'Marvel Cinematic Universe',
        tagline: 'The Infinity Saga & Multiverse Eras',
        icon: '⚡',
        bannerUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=1200&auto=format&fit=crop&q=80',
        description: 'Explore Earth\'s mightiest heroes from WWII origins to cosmic battles across time and space.',
        entries: [
          UniverseEntry(
            media: MediaItem(
              id: 1771,
              title: 'Captain America: The First Avenger',
              overview: 'Steve Rogers becomes Captain America during World War II.',
              posterPath: '/vSNxAJTlD0r02V9sPYpqjqDIFv6.jpg',
              backdropPath: '/yFuKvT42fGD82q57nxq0eydbvAe.jpg',
              voteAverage: 7.0,
              voteCount: 20000,
              releaseDate: '2011-07-22',
              genreIds: [28, 12, 878],
              mediaType: 'movie',
            ),
            releaseIndex: 5,
            chronologicalIndex: 1,
            timelineEra: '1942–1945 (World War II)',
            synopsisSnippet: 'The Super Soldier serum creates the First Avenger.',
          ),
          UniverseEntry(
            media: MediaItem(
              id: 1726,
              title: 'Iron Man',
              overview: 'Tony Stark builds an armored suit and becomes Iron Man.',
              posterPath: '/78lPtwv72eTNqFW9COBYI0dWDJa.jpg',
              backdropPath: '/cyecB7godJ6kNHGON0DGqdVNv92.jpg',
              voteAverage: 7.6,
              voteCount: 25000,
              releaseDate: '2008-05-02',
              genreIds: [28, 878, 12],
              mediaType: 'movie',
            ),
            releaseIndex: 1,
            chronologicalIndex: 2,
            timelineEra: '2010 (The Dawn of Heroes)',
            synopsisSnippet: 'Tony Stark reveals to the world: "I am Iron Man".',
          ),
          UniverseEntry(
            media: MediaItem(
              id: 24428,
              title: 'The Avengers',
              overview: 'Earth\'s mightiest heroes assemble against Loki\'s invasion.',
              posterPath: '/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg',
              backdropPath: '/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg',
              voteAverage: 7.7,
              voteCount: 29000,
              releaseDate: '2012-05-04',
              genreIds: [28, 12, 878],
              mediaType: 'movie',
            ),
            releaseIndex: 6,
            chronologicalIndex: 3,
            timelineEra: '2012 (The Battle of New York)',
            synopsisSnippet: 'Nick Fury\'s Avengers Initiative proves humanity can fight gods.',
          ),
          UniverseEntry(
            media: MediaItem(
              id: 299536,
              title: 'Avengers: Infinity War',
              overview: 'The Avengers face Thanos on a universe-shattering quest for the stones.',
              posterPath: '/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg',
              backdropPath: '/bOGkgRGdhrBYJSLpXaxhXVstddV.jpg',
              voteAverage: 8.3,
              voteCount: 28000,
              releaseDate: '2018-04-27',
              genreIds: [12, 28, 878],
              mediaType: 'movie',
            ),
            releaseIndex: 19,
            chronologicalIndex: 4,
            timelineEra: '2018 (The Cosmic Snap)',
            synopsisSnippet: 'Thanos gathers the Infinity Stones and wipes out half of all life.',
          ),
          UniverseEntry(
            media: MediaItem(
              id: 299534,
              title: 'Avengers: Endgame',
              overview: 'The surviving Avengers risk everything to reverse the tragedy.',
              posterPath: '/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
              backdropPath: '/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
              voteAverage: 8.3,
              voteCount: 24000,
              releaseDate: '2019-04-26',
              genreIds: [12, 878, 28],
              mediaType: 'movie',
            ),
            releaseIndex: 22,
            chronologicalIndex: 5,
            timelineEra: '2023 (The Time Heist)',
            synopsisSnippet: 'Whatever it takes. The epic climax of the Infinity Saga.',
          ),
        ],
      ),
      CinematicUniverse(
        id: 'starwars',
        title: 'Star Wars: The Skywalker Saga',
        tagline: 'A Galaxy Far, Far Away',
        icon: '🌌',
        bannerUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=1200&auto=format&fit=crop&q=80',
        description: 'From the fall of the Galactic Republic to the rise of the Resistance and the Jedi Order.',
        entries: [
          UniverseEntry(
            media: MediaItem(
              id: 1893,
              title: 'Star Wars: Episode I - The Phantom Menace',
              overview: 'Two Jedi rescue Queen Amidala while discovering a gifted boy.',
              posterPath: '/6wkfovpn7Eq89mgrL750Ahs0460.jpg',
              backdropPath: '/5Iw7zQHgdbUU9VvxfRTAi0xClZ.jpg',
              voteAverage: 6.5,
              voteCount: 14000,
              releaseDate: '1999-05-19',
              genreIds: [12, 28, 878],
              mediaType: 'movie',
            ),
            releaseIndex: 4,
            chronologicalIndex: 1,
            timelineEra: '32 BBY (Before Battle of Yavin)',
            synopsisSnippet: 'The discovery of Anakin Skywalker on Tatooine.',
          ),
          UniverseEntry(
            media: MediaItem(
              id: 11,
              title: 'Star Wars: Episode IV - A New Hope',
              overview: 'Luke Skywalker joins forces with a Jedi Knight and a cocky pilot to save the galaxy.',
              posterPath: '/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg',
              backdropPath: '/4qCqAdHcNUmYK8nb8jhvTfa7OAm.jpg',
              voteAverage: 8.2,
              voteCount: 19000,
              releaseDate: '1977-05-25',
              genreIds: [12, 28, 878],
              mediaType: 'movie',
            ),
            releaseIndex: 1,
            chronologicalIndex: 2,
            timelineEra: '0 BBY (The Destruction of the Death Star)',
            synopsisSnippet: 'The Rebel Alliance scores its first great victory against the Galactic Empire.',
          ),
          UniverseEntry(
            media: MediaItem(
              id: 1891,
              title: 'Star Wars: Episode V - The Empire Strikes Back',
              overview: 'The Empire pursues the Rebels, while Luke trains with Jedi Master Yoda.',
              posterPath: '/nDA9ijDuuUTeoY9GQ6iZq6v5Fnh.jpg',
              backdropPath: '/aJCtkxLLR9KnEJekQ22oxaqmu6w.jpg',
              voteAverage: 8.4,
              voteCount: 16000,
              releaseDate: '1980-05-21',
              genreIds: [12, 28, 878],
              mediaType: 'movie',
            ),
            releaseIndex: 2,
            chronologicalIndex: 3,
            timelineEra: '3 ABY (Cloud City & Revelations)',
            synopsisSnippet: 'Darth Vader delivers the most shocking twist in cinematic history.',
          ),
        ],
      ),
      CinematicUniverse(
        id: 'dune',
        title: 'The Dune Saga & Arrakis Chronicles',
        tagline: 'Fear is the Mind-Killer',
        icon: '🪐',
        bannerUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
        description: 'Denis Villeneuve\'s visual triumphs adapting Frank Herbert\'s legendary desert sci-fi epic.',
        entries: [
          UniverseEntry(
            media: MediaItem(
              id: 438631,
              title: 'Dune: Part One',
              overview: 'Paul Atreides leads nomadic tribes in a battle to control the desert planet Arrakis.',
              posterPath: '/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
              backdropPath: '/eeijXm355agTD315NXHQPyneUTL.jpg',
              voteAverage: 7.8,
              voteCount: 11000,
              releaseDate: '2021-09-15',
              genreIds: [878, 12],
              mediaType: 'movie',
            ),
            releaseIndex: 1,
            chronologicalIndex: 1,
            timelineEra: '10,191 AG (Fall of House Atreides)',
            synopsisSnippet: 'The great betrayal in the sand dunes of Arrakis.',
          ),
          UniverseEntry(
            media: MediaItem(
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
            releaseIndex: 2,
            chronologicalIndex: 2,
            timelineEra: '10,192 AG (Holy War of Muad\'Dib)',
            synopsisSnippet: 'Paul embraces prophecy, riding Shai-Hulud to reclaim the throne.',
          ),
        ],
      ),
    ];
  }
}
