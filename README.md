# favorite_places

A modern Favorite Places application built in Flutter using Material Design, created to learn and practice real-world Flutter concepts step by step.

Explore and save your favorite locations, view them on maps, and manage your collection with ease.

🧠 What I learned while building this
- Flutter widget tree & layouts
- Stateless vs Stateful widgets
- State management using setState
- BottomNavigationBar & IndexedStack
- Navigation & passing data between screens
- Drawer navigation
- Managing favorites logic
- Google Maps integration
- Location services & geocoding
- Reverse geocoding with Geoapify API
- Image picker & file handling
- Handling back navigation using PopScope
- Clean UI structure & code organization
- Git & GitHub workflow (building in public)

🚀 Features
- Browse and search favorite locations
- Add new places with location details
- View locations on interactive Google Maps
- Mark places as favorites ⭐
- Geoapify reverse geocoding for address lookup
- Static map previews for saved places
- Favorites tab with active management
- Beautiful Material Design UI
- Persistent data storage
- Clean and responsive interface

📦 Tech Stack
- Flutter (3.x)
- Dart
- Material Design
- Google Maps Flutter
- Geoapify API
- Location Services

## API Keys

This project requires a Geoapify API key for reverse geocoding and static map
previews. Do NOT commit your API key to version control. Provide the key at
compile/run time using Flutter's `--dart-define` option. Example:

```bash
# from the `favorite_places/` directory
flutter run --dart-define=GEOAPIFY_KEY=your_geoapify_key_here

# or when building a release
flutter build apk --dart-define=GEOAPIFY_KEY=your_geoapify_key_here
```

If you use CI or environment-based secrets, inject the `GEOAPIFY_KEY` into
the build command rather than storing it in the repository.

🚀 Run Locally
```bash
git clone https://github.com/Deepanshu-ui-dev/flutter-learning-favorite-places.git
cd favorite_places
flutter pub get
flutter run --dart-define=GEOAPIFY_KEY=your_geoapify_key_here
```
