import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'services/storage_service.dart';
import 'services/tmdb_service.dart';
import 'providers/media_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: FlickoraTheme.bgSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize storage
  final storageService = StorageService();
  await storageService.init();

  // Initialize TMDB service with stored custom key if present
  final customApiKey = storageService.getCustomApiKey();
  final tmdbService = TmdbService(apiKey: customApiKey ?? FlickoraConstants.defaultTmdbApiKey);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<TmdbService>.value(value: tmdbService),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(storageService, tmdbService),
        ),
        ChangeNotifierProvider<MediaProvider>(
          create: (_) => MediaProvider(tmdbService),
        ),
        ChangeNotifierProvider<WatchlistProvider>(
          create: (_) => WatchlistProvider(storageService),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(tmdbService, storageService),
        ),
      ],
      child: const FlickoraApp(),
    ),
  );
}

class FlickoraApp extends StatelessWidget {
  const FlickoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlickoraConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: FlickoraTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
