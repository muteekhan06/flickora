import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/cinephile_achievement.dart';
import '../services/storage_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<CinephileAchievement> _achievements = CinephileAchievement.getDefaultAchievements();

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'master':
        return Colors.purpleAccent;
      case 'gold':
        return Colors.amberAccent;
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final progress = _achievements.isEmpty ? 0.0 : unlockedCount / _achievements.length;

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Cinephile Trophies & Badges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2E220D), FlickoraTheme.bgCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hall of Trophies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('$unlockedCount / ${_achievements.length} Unlocked', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Earn badges by exploring masterworks, logging reviews, and passing trivia challenges.', style: TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary)),
                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Badges Grid
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _achievements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ach = _achievements[index];
              final tierColor = _getTierColor(ach.tier);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlickoraTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ach.isUnlocked ? tierColor.withOpacity(0.4) : Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ach.isUnlocked ? tierColor.withOpacity(0.15) : Colors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: ach.isUnlocked ? tierColor : Colors.white24),
                      ),
                      alignment: Alignment.center,
                      child: Text(ach.icon, style: TextStyle(fontSize: 24, color: ach.isUnlocked ? null : Colors.grey)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(ach.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ach.isUnlocked ? Colors.white : Colors.white60)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: tierColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                child: Text(ach.tier, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tierColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(ach.description, style: const TextStyle(fontSize: 11.5, color: FlickoraTheme.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('+${ach.xpReward} XP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ach.isUnlocked ? Colors.greenAccent : Colors.white30)),
                        const SizedBox(height: 4),
                        Icon(ach.isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 16, color: ach.isUnlocked ? Colors.greenAccent : Colors.white30),
                      ],
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
