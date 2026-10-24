import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/trivia_question.dart';
import '../services/storage_service.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  final List<TriviaQuestion> _deck = TriviaQuestion.getDailyDeck();
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _score = 0;
  int _userXp = 150;
  int _streak = 1;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  void _loadUserProgress() {
    final storage = StorageService();
    setState(() {
      _userXp = storage.getCinephileXp();
      _streak = storage.getTriviaStreak();
    });
  }

  void _submitAnswer(int index) async {
    if (_answered) return;

    final question = _deck[_currentIndex];
    final isCorrect = index == question.correctIndex;

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (isCorrect) {
        _score++;
        _userXp += 50;
      }
    });

    if (isCorrect) {
      await StorageService().addCinephileXp(50);
    }
  }

  void _nextQuestion() async {
    if (_currentIndex < _deck.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      });
    } else {
      await StorageService().incrementTriviaStreak();
      setState(() {
        _quizFinished = true;
        _streak++;
      });
    }
  }

  String _getCinephileRank(int xp) {
    if (xp >= 1000) return 'Cinema Grandmaster 👑';
    if (xp >= 500) return 'Auteur Scholar 🎓';
    if (xp >= 250) return 'Film Buff 🍿';
    return 'Cinephile Novice 🎟️';
  }

  @override
  Widget build(BuildContext context) {
    if (_quizFinished) {
      return Scaffold(
        backgroundColor: FlickoraTheme.bgDark,
        appBar: AppBar(title: const Text('Cinephile IQ Challenge', style: TextStyle(fontWeight: FontWeight.bold))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'Daily Challenge Completed!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored $_score / ${_deck.length} questions correctly',
                  style: const TextStyle(fontSize: 14, color: FlickoraTheme.textSecondary),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Rank:', style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 13)),
                          Text(_getCinephileRank(_userXp), style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Cinephile XP:', style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 13)),
                          Text('$_userXp XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Daily Streak:', style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 13)),
                          Text('$_streak Days 🔥', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _deck[_currentIndex];
    final progress = (_currentIndex + 1) / _deck.length;

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Cinephile IQ Challenge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$_userXp XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar & Question Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${_deck.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlickoraTheme.textMuted),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.category,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FlickoraTheme.accentRed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(FlickoraTheme.primaryRed),
              ),
            ),
            const SizedBox(height: 24),

            // Question Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                question.question,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
              ),
            ),

            const SizedBox(height: 20),

            // Options List
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final optionText = question.options[index];
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = index == question.correctIndex;

                  Color bgColor = FlickoraTheme.bgCard;
                  Color borderColor = Colors.white12;
                  Widget? trailingIcon;

                  if (_answered) {
                    if (isCorrect) {
                      bgColor = Colors.green.withOpacity(0.2);
                      borderColor = Colors.greenAccent;
                      trailingIcon = const Icon(Icons.check_circle_rounded, color: Colors.greenAccent);
                    } else if (isSelected) {
                      bgColor = Colors.red.withOpacity(0.2);
                      borderColor = Colors.redAccent;
                      trailingIcon = const Icon(Icons.cancel_rounded, color: Colors.redAccent);
                    }
                  }

                  return InkWell(
                    onTap: () => _submitAnswer(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white10,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              optionText,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          if (trailingIcon != null) trailingIcon,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Explanation & Next Button
            if (_answered) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FlickoraTheme.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Director\'s Note & Fact:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation,
                      style: const TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(_currentIndex < _deck.length - 1 ? 'Next Question →' : 'Complete Challenge 🏆'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
