import 'package:flutter/material.dart';
import '../core/theme.dart';

class CastNode {
  final String actorName;
  final String movieTitle;
  final String year;
  final String sharedRole;

  CastNode({
    required this.actorName,
    required this.movieTitle,
    required this.year,
    required this.sharedRole,
  });
}

class CastConnectionChain {
  final String actorA;
  final String actorB;
  final int degrees;
  final List<CastNode> path;

  CastConnectionChain({
    required this.actorA,
    required this.actorB,
    required this.degrees,
    required this.path,
  });
}

class CoStarConnectionScreen extends StatefulWidget {
  const CoStarConnectionScreen({super.key});

  @override
  State<CoStarConnectionScreen> createState() => _CoStarConnectionScreenState();
}

class _CoStarConnectionScreenState extends State<CoStarConnectionScreen> {
  final List<CastConnectionChain> _presets = [
    CastConnectionChain(
      actorA: 'Leonardo DiCaprio',
      actorB: 'Timothée Chalamet',
      degrees: 1,
      path: [
        CastNode(actorName: 'Leonardo DiCaprio', movieTitle: 'Don\'t Look Up', year: '2021', sharedRole: 'Co-starred directly together as Dr. Randall Mindy & Yule'),
        CastNode(actorName: 'Timothée Chalamet', movieTitle: 'Don\'t Look Up', year: '2021', sharedRole: 'Co-star connection completed in 1 step!'),
      ],
    ),
    CastConnectionChain(
      actorA: 'Cillian Murphy',
      actorB: 'Christian Bale',
      degrees: 1,
      path: [
        CastNode(actorName: 'Cillian Murphy', movieTitle: 'The Dark Knight Trilogy', year: '2005–2012', sharedRole: 'Jonathan Crane / Scarecrow against Bruce Wayne / Batman'),
        CastNode(actorName: 'Christian Bale', movieTitle: 'The Dark Knight Trilogy', year: '2005–2012', sharedRole: 'Direct Nolan collaborator connection'),
      ],
    ),
    CastConnectionChain(
      actorA: 'Zendaya',
      actorB: 'Matthew McConaughey',
      degrees: 2,
      path: [
        CastNode(actorName: 'Zendaya', movieTitle: 'Dune: Part One & Two', year: '2021–2024', sharedRole: 'Starred alongside Timothée Chalamet'),
        CastNode(actorName: 'Timothée Chalamet', movieTitle: 'Interstellar', year: '2014', sharedRole: 'Played young Tom Cooper alongside Cooper (Matthew McConaughey)'),
        CastNode(actorName: 'Matthew McConaughey', movieTitle: 'Interstellar', year: '2014', sharedRole: 'Connection bridged via Christopher Nolan masterwork in 2 degrees'),
      ],
    ),
    CastConnectionChain(
      actorA: 'Florence Pugh',
      actorB: 'Keanu Reeves',
      degrees: 2,
      path: [
        CastNode(actorName: 'Florence Pugh', movieTitle: 'Oppenheimer', year: '2023', sharedRole: 'Starred with Matt Damon'),
        CastNode(actorName: 'Matt Damon', movieTitle: 'The Bourne Identity', year: '2002', sharedRole: 'Bridged via Laurence Fishburne (Contagion) to The Matrix'),
        CastNode(actorName: 'Keanu Reeves', movieTitle: 'The Matrix', year: '1999', sharedRole: 'Neo & Trinity connection completed in 2 degrees'),
      ],
    ),
  ];

  late CastConnectionChain _selectedChain;

  @override
  void initState() {
    super.initState();
    _selectedChain = _presets.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Six Degrees of Co-Stars', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Explainer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlickoraTheme.primaryRed.withOpacity(0.2),
                  FlickoraTheme.bgCard,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FlickoraTheme.primaryRed.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.hub_outlined, color: FlickoraTheme.accentRed, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hollywood Cast Path Solver',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Discover the shortest connection path between legendary actors across cinema history.',
                        style: TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Preset Chips
          const Text('Select an Actor Pair:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlickoraTheme.textMuted)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((chain) {
              final isSelected = _selectedChain == chain;
              return ChoiceChip(
                label: Text('${chain.actorA.split(' ').first} ➔ ${chain.actorB.split(' ').first}'),
                selected: isSelected,
                selectedColor: FlickoraTheme.primaryRed,
                backgroundColor: FlickoraTheme.bgSurface,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : FlickoraTheme.textMuted,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(color: isSelected ? FlickoraTheme.primaryRed : Colors.white10),
                onSelected: (_) => setState(() => _selectedChain = chain),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Degree Badge & Actors Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FROM', style: TextStyle(fontSize: 10, color: FlickoraTheme.textMuted, fontWeight: FontWeight.bold)),
                          Text(_selectedChain.actorA, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        '${_selectedChain.degrees} Degree Path',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('TO', style: TextStyle(fontSize: 10, color: FlickoraTheme.textMuted, fontWeight: FontWeight.bold)),
                          Text(_selectedChain.actorB, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stepper Path
          const Text('Connection Stepper Path:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedChain.path.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: 2,
                height: 24,
                color: FlickoraTheme.primaryRed.withOpacity(0.4),
              ),
            ),
            itemBuilder: (context, index) {
              final step = _selectedChain.path[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FlickoraTheme.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: FlickoraTheme.primaryRed,
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.actorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Film: ${step.movieTitle} (${step.year})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                          const SizedBox(height: 4),
                          Text(step.sharedRole, style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted, height: 1.3)),
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
