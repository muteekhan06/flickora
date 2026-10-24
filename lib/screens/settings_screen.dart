import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/settings_provider.dart';
import '../providers/media_provider.dart';
import '../services/storage_service.dart';
import 'double_feature_screen.dart';
import 'awards_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showApiKeyDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.customApiKey ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FlickoraTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: FlickoraTheme.accentRed, size: 22),
              SizedBox(width: 8),
              Text('TMDB API Key', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flickora provides a default demo key. If you have your own personal TMDB API key from themoviedb.org, enter it below for higher rate limits:',
                style: TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter TMDB API Key',
                  hintStyle: const TextStyle(color: FlickoraTheme.textMuted),
                  filled: true,
                  fillColor: FlickoraTheme.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                settings.setCustomApiKey(null);
                context.read<MediaProvider>().refresh();
                Navigator.pop(context);
              },
              child: const Text('Reset Default', style: TextStyle(color: FlickoraTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                settings.setCustomApiKey(controller.text);
                context.read<MediaProvider>().refresh();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showQualityDialog(BuildContext context, SettingsProvider settings) {
    final qualities = ['Auto (Adaptive)', '720p HD', '1080p Ultra HD', '4K UHD HDR'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FlickoraTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Default Stream Quality', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: qualities.map((q) {
              final isSelected = settings.streamQuality == q;
              return ListTile(
                title: Text(q, style: TextStyle(color: isSelected ? FlickoraTheme.accentRed : Colors.white, fontSize: 14)),
                trailing: isSelected ? const Icon(Icons.check, color: FlickoraTheme.accentRed) : null,
                onTap: () {
                  settings.setStreamQuality(q);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FlickoraTheme.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/flickora_logo.png', width: 64, height: 64),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (b) => FlickoraTheme.primaryGradient.createShader(b),
                child: const Text(
                  'FLICKORA',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
                ),
              ),
              const Text('Version 1.4.0 (The Master Edition)', style: TextStyle(fontSize: 11, color: FlickoraTheme.textMuted)),
              const SizedBox(height: 14),
              const Text(
                'Flickora is a next-generation streaming & media exploration app built with Flutter and Dart. Designed with a strict zero-ad policy, delivering ultra-fluid animations, 4K metadata discovery, and personalized watchlists.\n\nBuilt for University Project & Portfolio Showcase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: FlickoraTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              const Text(
                'Data provided by TMDB. All trademarks and media rights belong to their respective owners.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: FlickoraTheme.textMuted),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: FlickoraTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          'Settings & Profile',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Banner
          Container(
            padding: const EdgeInsets.all(18),
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/flickora_logo.png',
                    width: 56,
                    height: 56,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flickora VIP',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ad-Free Premium Lifetime Access',
                        style: TextStyle(fontSize: 12, color: FlickoraTheme.accentRed, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.verified_rounded, color: FlickoraTheme.accentRed, size: 24),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Playback Settings Section
          _buildSectionHeader('STREAMING PREFERENCES'),
          _buildTile(
            icon: Icons.hd_rounded,
            title: 'Default Video Quality',
            subtitle: settings.streamQuality,
            onTap: () => _showQualityDialog(context, settings),
          ),
          _buildTile(
            icon: Icons.data_saver_on_rounded,
            title: 'Data Saver',
            subtitle: 'Reduce streaming bitrate on cellular data',
            trailing: Switch(
              value: false,
              activeColor: FlickoraTheme.primaryRed,
              onChanged: (val) {},
            ),
          ),

          const SizedBox(height: 24),

          // Cinema Vaults & Marathons
          _buildSectionHeader('CINEMA VAULTS & MARATHONS'),
          _buildTile(
            icon: Icons.movie_filter_rounded,
            title: 'Double Feature Generator',
            subtitle: 'Curated 2-movie back-to-back marathon pairings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoubleFeatureScreen()),
              );
            },
          ),
          _buildTile(
            icon: Icons.military_tech_rounded,
            title: 'Awards Season & Oscar Vault',
            subtitle: 'All-time Academy Award & Palme d\'Or masterworks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AwardsScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Catalog & Data Portability
          _buildSectionHeader('DATA PORTABILITY & SYNC'),
          _buildTile(
            icon: Icons.file_download_outlined,
            title: 'Export to Letterboxd (CSV)',
            subtitle: 'Export your watchlist & ratings in official Letterboxd format',
            onTap: () async {
              final csv = await StorageService().exportLetterboxdCsv();
              await Clipboard.setData(ClipboardData(text: csv));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Letterboxd CSV copied to clipboard! Ready to import on letterboxd.com'),
                    backgroundColor: FlickoraTheme.accentRed,
                  ),
                );
              }
            },
          ),
          _buildTile(
            icon: Icons.key_rounded,
            title: 'TMDB API Key',
            subtitle: settings.hasCustomApiKey ? 'Custom Key Active' : 'Default Public Key',
            onTap: () => _showApiKeyDialog(context, settings),
          ),
          _buildTile(
            icon: Icons.delete_sweep_rounded,
            title: 'Clear Cache & History',
            subtitle: 'Free up local cache and reset state',
            onTap: () async {
              await settings.clearAllAppData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All local cache and preferences cleared.')),
              );
            },
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('ABOUT FLICKORA'),
          _buildTile(
            icon: Icons.info_outline_rounded,
            title: 'About Flickora',
            subtitle: 'v${FlickoraConstants.appVersion} • No Ads • Open Source',
            onTap: () => _showAboutDialog(context),
          ),
          _buildTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy & Terms',
            subtitle: 'University research & non-commercial portfolio',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy: No user data is tracked or sold.')),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: FlickoraTheme.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FlickoraTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ListTile(
        leading: Icon(icon, color: FlickoraTheme.accentRed, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: FlickoraTheme.textMuted))
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: FlickoraTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
