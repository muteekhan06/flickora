import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../models/release_reminder.dart';
import '../services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<ReleaseReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _reminders = StorageService().getReminders();
    });
  }

  void _removeReminder(int mediaId) async {
    final reminder = _reminders.firstWhere((r) => r.mediaId == mediaId);
    await StorageService().toggleReminder(reminder);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text('Release Radar & Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlickoraTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: const [
                Icon(Icons.notifications_active_rounded, color: Colors.amberAccent, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Release Reminders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Get live alerts when your tracked films hit theaters and digital streaming platforms.', style: TextStyle(fontSize: 11, color: FlickoraTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User Tracked Reminders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Tracked Drops', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${_reminders.length} Active', style: const TextStyle(fontSize: 11, color: FlickoraTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 12),

          if (_reminders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FlickoraTheme.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.radar_outlined, size: 40, color: FlickoraTheme.textMuted),
                  SizedBox(height: 10),
                  Text('No release reminders set yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Tap the bell icon on any upcoming title in Release Radar to track its premiere.', textAlign: TextAlign.center, style: TextStyle(color: FlickoraTheme.textMuted, fontSize: 11)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = _reminders[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FlickoraTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: r.posterPath.startsWith('http') ? r.posterPath : 'https://image.tmdb.org/t/p/w200${r.posterPath}',
                          width: 48,
                          height: 70,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                            const SizedBox(height: 4),
                            Text('Releasing: ${r.releaseDate}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                            const SizedBox(height: 2),
                            const Text('Notification active: Ready for drop', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_off_outlined, color: FlickoraTheme.textMuted, size: 20),
                        tooltip: 'Cancel Reminder',
                        onPressed: () => _removeReminder(r.mediaId),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 32),

          // Global Festival & Premiere Feed
          const Text('Live Industry Radar Broadcasts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          _buildBroadcastItem('Venice & Toronto Film Festival Slates Announced', 'Over 40 Cannes and Venice selections scheduled for global streaming debuts this winter.', '2h ago', Icons.festival_rounded),
          const SizedBox(height: 10),
          _buildBroadcastItem('IMAX 70mm Special Re-Releases', 'Christopher Nolan\'s Interstellar and Oppenheimer returning to select 70mm screens.', '1d ago', Icons.camera_roll_rounded),
          const SizedBox(height: 10),
          _buildBroadcastItem('Academy Awards Season Calendar', 'Final voting windows and Oscar nominations countdown underway.', '3d ago', Icons.military_tech_rounded),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBroadcastItem(String title, String body, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: FlickoraTheme.accentRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1),
                    ),
                    Text(time, style: const TextStyle(fontSize: 10, color: FlickoraTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 11, color: FlickoraTheme.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
