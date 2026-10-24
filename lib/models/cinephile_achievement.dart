class CinephileAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String tier; // Gold, Silver, Bronze, Master
  final int xpReward;
  final bool isUnlocked;

  CinephileAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.xpReward,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'tier': tier,
    'xpReward': xpReward,
    'isUnlocked': isUnlocked,
  };

  factory CinephileAchievement.fromJson(Map<String, dynamic> json) => CinephileAchievement(
    id: json['id'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '🏆',
    tier: json['tier'] ?? 'Bronze',
    xpReward: json['xpReward'] ?? 50,
    isUnlocked: json['isUnlocked'] ?? false,
  );

  static List<CinephileAchievement> getDefaultAchievements() {
    return [
      CinephileAchievement(
        id: 'ach_first_film',
        title: 'Curtain Raiser',
        description: 'Streamed your very first film in Flickora',
        icon: '🎬',
        tier: 'Bronze',
        xpReward: 50,
        isUnlocked: true,
      ),
      CinephileAchievement(
        id: 'ach_diary_logger',
        title: 'Master Archivist',
        description: 'Logged your first 5-star review in the Cinema Diary',
        icon: '📖',
        tier: 'Bronze',
        xpReward: 75,
        isUnlocked: true,
      ),
      CinephileAchievement(
        id: 'ach_sound_lab',
        title: 'Acoustic Audiophile',
        description: 'Activated a custom DSP profile in the Cinema Sound Lab',
        icon: '🎚️',
        tier: 'Silver',
        xpReward: 100,
        isUnlocked: true,
      ),
      CinephileAchievement(
        id: 'ach_trivia_streak',
        title: 'Cinephile Scholar',
        description: 'Completed a daily 5-question Cinephile IQ Challenge',
        icon: '🧠',
        tier: 'Silver',
        xpReward: 125,
        isUnlocked: true,
      ),
      CinephileAchievement(
        id: 'ach_marathon_master',
        title: 'Marathon Grandmaster',
        description: 'Completed an entire 2-film curated Double Feature',
        icon: '🍿',
        tier: 'Gold',
        xpReward: 200,
        isUnlocked: false,
      ),
      CinephileAchievement(
        id: 'ach_universe_explorer',
        title: 'Chronology Navigator',
        description: 'Explored a cinematic franchise in in-universe chronological sequence',
        icon: '🪐',
        tier: 'Gold',
        xpReward: 250,
        isUnlocked: false,
      ),
      CinephileAchievement(
        id: 'ach_festival_connoisseur',
        title: 'Palme d\'Or Connoisseur',
        description: 'Streamed an official Cannes or Venice trophy winner',
        icon: '🌿',
        tier: 'Master',
        xpReward: 500,
        isUnlocked: false,
      ),
    ];
  }
}
