# favorite_places

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
