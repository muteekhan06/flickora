class CinemaQuote {
  final String id;
  final String quote;
  final String character;
  final String actor;
  final String movieTitle;
  final String year;
  final String posterUrl;
  final String sceneContext;

  CinemaQuote({
    required this.id,
    required this.quote,
    required this.character,
    required this.actor,
    required this.movieTitle,
    required this.year,
    required this.posterUrl,
    required this.sceneContext,
  });

  static List<CinemaQuote> getIconicQuotes() {
    return [
      CinemaQuote(
        id: 'quote_1',
        quote: 'Do not go gentle into that good night. Rage, rage against the dying of the light.',
        character: 'Professor Brand / Cooper',
        actor: 'Michael Caine / Matthew McConaughey',
        movieTitle: 'Interstellar',
        year: '2014',
        posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        sceneContext: 'Recited as the Endurance space vessel leaves Earth\'s gravitational atmosphere.',
      ),
      CinemaQuote(
        id: 'quote_2',
        quote: 'You either die a hero, or you live long enough to see yourself become the villain.',
        character: 'Harvey Dent',
        actor: 'Aaron Eckhart',
        movieTitle: 'The Dark Knight',
        year: '2008',
        posterUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        sceneContext: 'Spoken during dinner with Bruce Wayne and Rachel Dawes at Gotham restaurant.',
      ),
      CinemaQuote(
        id: 'quote_3',
        quote: 'I\'ve seen things you people wouldn\'t believe... Attack ships on fire off the shoulder of Orion.',
        character: 'Roy Batty',
        actor: 'Rutger Hauer',
        movieTitle: 'Blade Runner',
        year: '1982',
        posterUrl: 'https://image.tmdb.org/t/p/w500/63N9uy8nd9j7Eog2axPQ8lbr3Wj.jpg',
        sceneContext: 'The immortal "Tears in Rain" soliloquy delivered on the rain-soaked rooftop.',
      ),
      CinemaQuote(
        id: 'quote_4',
        quote: 'Fear is the mind-killer. Fear is the little-death that brings total obliteration.',
        character: 'Paul Atreides',
        actor: 'Timothée Chalamet',
        movieTitle: 'Dune: Part One',
        year: '2021',
        posterUrl: 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
        sceneContext: 'Recited during the Gom Jabbar test of nerve pain endurance with the Reverend Mother.',
      ),
      CinemaQuote(
        id: 'quote_5',
        quote: 'May the Force be with you.',
        character: 'General Dodonna / Han Solo',
        actor: 'Alex McCrindle / Harrison Ford',
        movieTitle: 'Star Wars: A New Hope',
        year: '1977',
        posterUrl: 'https://image.tmdb.org/t/p/w500/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg',
        sceneContext: 'Said to the Rebel pilots right before departing to attack the Death Star.',
      ),
    ];
  }
}
