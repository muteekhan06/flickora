# 🎬 Flickora — Premium Ad-Free Movies & Series App

<p align="center">
  <img src="assets/images/flickora_logo.png" alt="Flickora Logo" width="140" style="border-radius: 24px; box-shadow: 0 10px 30px rgba(229, 9, 20, 0.4);" />
</p>

<p align="center">
  <strong>Stream, Explore, and Track Endless Entertainment — With Zero In-App Ads.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-E50914" alt="Platform" />
  <img src="https://img.shields.io/badge/Ads-Strictly%20Zero-success" alt="Zero Ads" />
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white" alt="GitHub Actions" />
</p>

---

## 🌟 Overview

**Flickora** is a cinema-tier mobile application crafted in Flutter and Dart, engineered to deliver a sleek, Netflix-grade user experience for discovering movies, series, and anime. Designed from the ground up as a clean, ethical, ad-free alternative to bloated piracy wrappers like MovieBox, Flickora combines modern Material 3 aesthetics, fluid animations, offline metadata resiliency, and TMDB integration.

---

## ✨ Key Features

- **🚫 Strictly 100% Ad-Free**: No popups, no interstitial video ads, no banners, and zero third-party trackers.
- **🎨 Cinematic Dark UI**: Deep cosmic blacks (`#090A0E`), crimson red gradients (`#E50914`), and crisp typography.
- **🎞️ Official 3D Filmstrip Branding**: Custom app icon mipmaps, animated splash reveal, and matching color system.
- **🔥 Dynamic Hero Carousel**: Auto-sliding banner showcasing trending titles with instant "Watch Trailer" and "+ Watchlist" actions.
- **🔟 Netflix-Style Top 10 Row**: Bold numbered overlay rankings highlighting the top 10 movies and series worldwide.
- **⏯️ Continue Watching**: Automatic playback progress tracking with red progress bars and resume buttons.
- **🔍 Instant Debounced Search**: Live query execution, trending search chips, and recent search history management.
- **🎭 Explore by Genre**: Category switchers (Movies, TV Shows, Anime) paired with genre filter chips.
- **🎬 Rich Detail Screen**:
  - Parallax backdrop header with gradient vignetting.
  - Runtime, release year, age ratings, and 4K UHD badges.
  - Cast & Crew horizontal carousel with actor avatars and character names.
  - Official YouTube trailers and teaser clips.
  - "More Like This" recommendations.
  - Offline download resolution selector modal.
- **▶️ In-App HD Trailer Player**: Fullscreen player with scrubber, audio indicators, and playback state tracking.
- **📚 Personal Library**: Multi-tab management for **Watchlist**, **Favorites**, and **History**.
- **⚙️ Configurable Settings**:
  - Custom TMDB API Key input (allows using your own key or the default discovery key).
  - Default video quality selection (Auto, 720p HD, 1080p Ultra HD, 4K HDR).
  - Cache clearing and data reset.
- **🛡️ Offline Resiliency**: Built-in fallback catalog ensures the app never crashes or displays a blank screen even when offline or rate-limited.

---

## 📁 Architecture & Code Organization

```
lib/
├── core/
│   ├── constants.dart      # TMDB endpoints, image builders, fallback catalog
│   └── theme.dart          # Flickora dark theme, gradients, typography
├── models/
│   ├── cast.dart           # Cast & crew model
│   ├── media_item.dart     # Core movie & TV show model
│   └── trailer.dart        # Video trailer model
├── providers/
│   ├── media_provider.dart    # Trending, popular, top rated catalog state
│   ├── search_provider.dart   # Live search and genre filtering state
│   ├── settings_provider.dart # User preferences and API key state
│   └── watchlist_provider.dart# Watchlist, favorites, and continue watching state
├── screens/
│   ├── detail_screen.dart     # Cinematic movie detail screen
│   ├── explore_screen.dart    # Category and genre exploration grid
│   ├── home_screen.dart       # Main streaming home with hero banner & rows
│   ├── main_nav_screen.dart   # Bottom navigation bar host
│   ├── player_screen.dart     # Video/trailer player screen
│   ├── search_screen.dart     # Search screen with history
│   ├── settings_screen.dart   # Settings, API config, profile, and about
│   ├── splash_screen.dart     # Logo pulse animation
│   └── watchlist_screen.dart  # Multi-tab library
├── services/
│   ├── storage_service.dart   # SharedPreferences persistence
│   └── tmdb_service.dart      # TMDB API client with offline fallback
├── widgets/
│   ├── cast_card.dart         # Circular cast card
│   ├── custom_badge.dart      # 4K, HD, and rating badges
│   ├── hero_carousel.dart     # Top auto-sliding carousel
│   ├── movie_card.dart        # Poster card with hero animations
│   ├── section_header.dart    # Category header with accent bar
│   └── shimmer_loader.dart    # Skeleton shimmer effects
└── main.dart                  # Application entrypoint & MultiProvider setup
```

---

## 🚀 Building the Release APK via GitHub Actions

Because this repository includes a complete automated CI/CD workflow in `.github/workflows/build_apk.yml`, you do not need the Android SDK or Flutter installed on your local machine to build the APK!

### How to trigger the automated build:

1. **Push to your GitHub repository**:
   ```bash
   git add .
   git commit -m "feat: complete Flickora Flutter app with zero ads and GitHub Actions CI"
   git branch -M main
   git remote add origin https://github.com/<your-username>/flickora.git
   git push -u origin main
   ```

2. **Watch the Build**:
   - Go to your repository on GitHub.
   - Click the **Actions** tab.
   - You will see the **Build Flickora APK** workflow running.

3. **Download your APK**:
   - Once the workflow completes (~3-4 minutes), click on the completed run.
   - Scroll down to the **Artifacts** section at the bottom.
   - Click **`flickora-release-apk`** to download the `app-release.apk` directly to your phone or PC!

4. **Optional: Create an Official Release**:
   - Pushing a git tag (e.g. `git tag v1.0.0 && git push origin v1.0.0`) automatically publishes a GitHub Release with the APK attached.

---

## 💻 Local Development Setup (Optional)

If you have Flutter installed locally:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit tests
flutter test

# 3. Launch in debug mode (on an emulator or connected device)
flutter run

# 4. Build release APK locally
flutter build apk --release
```

---

## 📜 License & Disclaimers

- Developed for academic research, education, and university project demonstration.
- Media metadata and artwork provided by [The Movie Database (TMDB)](https://www.themoviedb.org/).
- YouTube trailer playback powered by the YouTube IFrame API.
