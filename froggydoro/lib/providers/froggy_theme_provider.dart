// lib/providers/froggy_theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FroggyTheme {
  final String name;
  final String workImage;
  final String breakImage;
  final String description;

  const FroggyTheme({
    required this.name,
    required this.workImage,
    required this.breakImage,
    required this.description,
  });
}

class FroggyThemeNotifier extends StateNotifier<FroggyTheme> {
  FroggyThemeNotifier() : super(_defaultTheme) {
    _loadFroggyTheme();
  }

  static const FroggyTheme _defaultTheme = FroggyTheme(
    name: 'Computer Froggy',
    workImage: 'assets/froggy/work_compuper_froggy.png',
    breakImage: 'assets/froggy/rest_compuper_froggy.png', // Fixed path
    description: 'Working hard on the compuper',
  );

  static const List<FroggyTheme> availableThemes = [
    _defaultTheme,
    FroggyTheme(
      name: 'Booky Froggy',
      workImage: 'assets/froggy/work_booky_froggy.png',
      breakImage: 'assets/froggy/rest_music_froggy.png', // Fixed path
      description: 'Very focused. Very booky.',
    ),
    FroggyTheme(
      name: 'Glass Froggy',
      workImage: 'assets/froggy/work_glass_froggy.png',
      breakImage: 'assets/froggy/rest_glass_froggy.png', // Fixed path
      description: 'Glassy and focused',
    ),
  ];

  Future<void> setFroggyTheme(FroggyTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_froggy_theme', theme.name);
  }

  Future<void> _loadFroggyTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeName = prefs.getString('selected_froggy_theme');

    if (savedThemeName != null) {
      final savedTheme = availableThemes.firstWhere(
        (theme) => theme.name == savedThemeName,
        orElse: () => _defaultTheme,
      );
      state = savedTheme;
    }
  }
}

final froggyThemeProvider =
    StateNotifierProvider<FroggyThemeNotifier, FroggyTheme>(
      (ref) => FroggyThemeNotifier(),
    );
