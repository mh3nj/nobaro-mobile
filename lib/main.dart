import 'package:flutter/material.dart';
import 'design/theme_provider.dart';
import 'design/nobaro_theme.dart';
import 'design/theme_definitions.dart';
import 'features/splash/splash_screen.dart';
import 'features/today/today_screen.dart';
import 'features/timeline/timeline_screen.dart';
import 'features/editor/editor_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/ascii_art/ascii_gallery_screen.dart';
import 'features/screensaver/screensaver_screen.dart';
import 'features/templates/templates_screen.dart';
import 'features/help/help_screen.dart';
import 'features/search/advanced_search_screen.dart';
import 'core/models/note.dart';
import 'router/app_router.dart';
import 'data/session_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NobaroApp());
}

class NobaroApp extends StatefulWidget {
  const NobaroApp({super.key});

  @override
  State<NobaroApp> createState() => _NobaroAppState();
}

class _NobaroAppState extends State<NobaroApp> {
  NobaroThemeData _currentTheme = ThemeDefinitions.all['Classic DOS']!;
  final SessionState _session = SessionState();

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    await _session.initialize();
    final saved = ThemeDefinitions.all[_session.player.theme];
    if (saved != null && mounted) {
      setState(() => _currentTheme = saved);
    }
  }

  void _changeTheme(String name) {
    final theme = ThemeDefinitions.all[name];
    if (theme != null) {
      setState(() => _currentTheme = theme);
      _session.player.theme = name;
      _session.playerRepo.save(_session.player);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NobaroTheme(
      data: _currentTheme,
      child: MaterialApp(
        title: 'Nobaro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _currentTheme.background,
          colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: _currentTheme.primary,
            onPrimary: _currentTheme.onPrimary,
            primaryContainer: _currentTheme.primaryContainer,
            onPrimaryContainer: _currentTheme.onPrimaryContainer,
            secondary: _currentTheme.secondary,
            onSecondary: _currentTheme.onSecondary,
            secondaryContainer: _currentTheme.secondaryContainer,
            onSecondaryContainer: _currentTheme.onSecondaryContainer,
            tertiary: _currentTheme.tertiary,
            onTertiary: _currentTheme.onTertiary,
            tertiaryContainer: _currentTheme.tertiaryContainer,
            onTertiaryContainer: _currentTheme.onTertiaryContainer,
            error: _currentTheme.error,
            onError: _currentTheme.onError,
            errorContainer: _currentTheme.errorContainer,
            onErrorContainer: _currentTheme.onErrorContainer,
            surface: _currentTheme.surface,
            onSurface: _currentTheme.onSurface,
            outline: _currentTheme.outline,
            outlineVariant: _currentTheme.outlineVariant,
            inverseSurface: _currentTheme.inverseSurface,
            inversePrimary: _currentTheme.primary,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w700),
            displayMedium: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w700),
            displaySmall: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w700),
            headlineLarge: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
            headlineMedium: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
            titleLarge: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontFamily: 'JetBrainsMono'),
            bodyMedium: TextStyle(fontFamily: 'JetBrainsMono'),
            bodySmall: TextStyle(fontFamily: 'JetBrainsMono'),
            labelLarge: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w500),
            labelMedium: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w500),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          AppRouter.onboarding: (context) => const OnboardingScreen(),
          AppRouter.today: (context) => const TodayScreen(),
          AppRouter.timeline: (context) => const TimelineScreen(),
          AppRouter.editor: (context) {
            final note = ModalRoute.of(context)?.settings.arguments;
            return EditorScreen(note: note as Note?);
          },
          AppRouter.settings: (context) => SettingsScreen(
            onThemeChanged: _changeTheme,
          ),
          AppRouter.asciiGallery: (context) => const AsciiGalleryScreen(),
          AppRouter.templates: (context) => const TemplatesScreen(),
          AppRouter.screensaver: (context) => const ScreensaverScreen(),
          AppRouter.help: (context) => const HelpScreen(),
          AppRouter.advancedSearch: (context) => const AdvancedSearchScreen(),
        },
      ),
    );
  }
}
