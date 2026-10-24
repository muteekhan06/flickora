class TriviaQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;
  final String difficulty;

  TriviaQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });

  static List<TriviaQuestion> getDailyDeck() {
    return [
      TriviaQuestion(
        id: 'q1',
        question: 'In Christopher Nolan\'s "Interstellar", how many Earth years equal one hour on Miller\'s water planet?',
        options: ['1 Year', '7 Years', '12 Years', '23 Years'],
        correctIndex: 1,
        explanation: 'Due to the supermassive black hole Gargantua\'s intense gravitational time dilation, 1 hour on Miller\'s planet equals 7 years on Earth.',
        category: 'Sci-Fi Masterworks',
        difficulty: 'Medium',
      ),
      TriviaQuestion(
        id: 'q2',
        question: 'Which legendary film was the first animated movie ever nominated for the Academy Award for Best Picture?',
        options: ['The Lion King', 'Spirited Away', 'Beauty and the Beast', 'Toy Story'],
        correctIndex: 2,
        explanation: 'Disney\'s "Beauty and the Beast" (1991) made history as the very first animated feature nominated for Best Picture at the Academy Awards.',
        category: 'Oscar History',
        difficulty: 'Hard',
      ),
      TriviaQuestion(
        id: 'q3',
        question: 'In Quentin Tarantino\'s "Pulp Fiction", what is the combination to open Marsellus Wallace\'s glowing briefcase?',
        options: ['777', '666', '007', '1994'],
        correctIndex: 1,
        explanation: 'The briefcase lock combination is 666, which sparked decades of fan theories regarding what was inside the golden glow.',
        category: 'Cult Classics',
        difficulty: 'Medium',
      ),
      TriviaQuestion(
        id: 'q4',
        question: 'Which camera format was primarily used by Denis Villeneuve and Greig Fraser to film "Dune: Part Two"?',
        options: ['35mm Kodachrome', 'Arri Alexa LF / Mini LF (IMAX Certified)', 'Sony Handycam 4K', 'Panavision 16mm'],
        correctIndex: 1,
        explanation: 'Dune: Part Two was filmed with Arri Alexa LF and Mini LF large-format digital cameras certified for IMAX 1.43:1 and 1.90:1 presentation.',
        category: 'Cinematography',
        difficulty: 'Hard',
      ),
      TriviaQuestion(
        id: 'q5',
        question: 'In "The Lord of the Rings: The Fellowship of the Ring", who says: "One does not simply walk into Mordor"?',
        options: ['Aragorn', 'Gandalf', 'Boromir', 'Legolas'],
        correctIndex: 2,
        explanation: 'Boromir (portrayed by Sean Bean) famously delivers this line during the Council of Elrond in Rivendell.',
        category: 'Fantasy Epics',
        difficulty: 'Easy',
      ),
      TriviaQuestion(
        id: 'q6',
        question: 'Which movie won the Palme d\'Or at Cannes before going on to win Best Picture at the 92nd Academy Awards in 2020?',
        options: ['The Zone of Interest', 'Parasite', 'Anatomy of a Fall', 'Triangle of Sadness'],
        correctIndex: 1,
        explanation: 'Bong Joon-ho\'s "Parasite" (2019) accomplished this historic double sweep, winning both the Cannes Palme d\'Or and Oscar Best Picture.',
        category: 'World Cinema',
        difficulty: 'Medium',
      ),
      TriviaQuestion(
        id: 'q7',
        question: 'What iconic prop did Heath Ledger improve on the fly during the hospital explosion in "The Dark Knight"?',
        options: ['The detonator fidgeting', 'His nurse outfit', 'His pocket knife', 'The shotgun cocking'],
        correctIndex: 0,
        explanation: 'When the pyrotechnic timing lagged slightly, Ledger stayed completely in character, pausing and aggressively smacking the detonator until the big blast went off.',
        category: 'Behind The Scenes',
        difficulty: 'Medium',
      ),
    ];
  }
}
