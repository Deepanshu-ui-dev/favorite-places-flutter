import 'package:favorite_places/screens/places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_fonts/google_fonts.dart';

// Define a new, more vibrant and modern color scheme
final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 131, 57, 0), // A warm, earthy tone
  // Primary colors for the app
  primary: const Color.fromARGB(255, 255, 167, 38), // A vibrant orange
  onPrimary: Colors.black, // Text on primary color
  primaryContainer: const Color.fromARGB(255, 186, 104, 0), // A darker orange for containers
  onPrimaryContainer: Colors.white, // Text on primary container
  // Secondary colors for accents
  secondary: const Color.fromARGB(255, 255, 202, 40), // A bright yellow
  onSecondary: Colors.black, // Text on secondary color
  secondaryContainer: const Color.fromARGB(255, 255, 238, 130), // A lighter yellow for containers
  onSecondaryContainer: Colors.black, // Text on secondary container
  // Tertiary colors for additional accents
  tertiary: const Color.fromARGB(255, 128, 222, 234), // A light blue
  onTertiary: Colors.black, // Text on tertiary color
  tertiaryContainer: const Color.fromARGB(255, 0, 188, 212), // A vibrant cyan for containers
  onTertiaryContainer: Colors.black, // Text on tertiary container
  // Error colors
  error: const Color.fromARGB(255, 255, 82, 82), // A bright red
  onError: Colors.white, // Text on error color
  errorContainer: const Color.fromARGB(255, 229, 57, 53), // A darker red for error containers
  onErrorContainer: Colors.white, // Text on error container
  // Background and surface colors
  background: const Color.fromARGB(255, 20, 20, 20), // A very dark grey for the main background
  onBackground: Colors.white, // Text on background
  surface: const Color.fromARGB(255, 30, 30, 30), // A slightly lighter dark grey for surfaces
  onSurface: Colors.white, // Text on surface
  surfaceVariant: const Color.fromARGB(255, 50, 50, 50), // A darker grey for surface variants
  onSurfaceVariant: Colors.white, // Text on surface variant
  outline: const Color.fromARGB(255, 100, 100, 100), // A grey for outlines
  shadow: Colors.black.withOpacity(0.5), // A dark shadow
  inverseSurface: Colors.white, // Inverse surface color
  onInverseSurface: Colors.black, // Text on inverse surface
  inversePrimary: const Color.fromARGB(255, 0, 0, 0), // Inverse primary color
  surfaceTint: const Color.fromARGB(255, 255, 167, 38), // Surface tint color
);

final theme = ThemeData().copyWith(
  useMaterial3: true,
  scaffoldBackgroundColor: colorScheme.background, // Use the defined background color
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onBackground,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onBackground,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
      color: colorScheme.onBackground,
    ),
    bodyMedium: GoogleFonts.ubuntuCondensed(
      color: colorScheme.onBackground,
    ),
    labelSmall: GoogleFonts.ubuntuCondensed(
      color: colorScheme.onBackground,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.primaryContainer,
    foregroundColor: colorScheme.onPrimaryContainer,
    elevation: 4,
    shadowColor: colorScheme.shadow,
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: GoogleFonts.ubuntuCondensed(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      textStyle: GoogleFonts.ubuntuCondensed(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
    prefixIconColor: colorScheme.primary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: colorScheme.secondaryContainer,
    foregroundColor: colorScheme.onSecondaryContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Great Places',
      theme: theme,
      home: Builder(
        builder: (context) {
          // To apply a gradient background to the entire app or a specific screen,
          // you need to wrap the Scaffold's body with a Container that has a BoxDecoration with a LinearGradient.
          // ThemeData's scaffoldBackgroundColor does not directly support gradients.
          // Here's an example of how you might apply a gradient to the PlacesScreen's body:
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.background, // Start with the background color from the theme
                    Theme.of(context).colorScheme.surface, // Transition to a slightly lighter surface color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const PlacesScreen(),
            ),
          );
        },
      ),
    );
  }
}

