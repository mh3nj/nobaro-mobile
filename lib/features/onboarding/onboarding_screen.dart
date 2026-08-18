import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../core/utils/sound_manager.dart';
import '../../router/app_router.dart';
import '../../data/session_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late String _season;
  late List<String> _artLines;

  @override
  void initState() {
    super.initState();
    final month = DateTime.now().month;
    _season = _getSeason(month);
    _artLines = _getArt(_season);
  }

  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  List<String> _getArt(String season) {
    switch (season) {
      case 'spring':
        return [
          '      .   .   .   .   .   ',
          '    .   .   .    .   .    ',
          '       _.-"""-._          ',
          '     .\'  o   o  \'.        ',
          '    /   o     o   \\       ',
          '   |  o    o    o  |      ',
          '    \\   o     o   /       ',
          '     \'._       _.\'        ',
          '        \'-...-\'           ',
          '          | |             ',
          '       ___|_|___          ',
        ];
      case 'summer':
        return [
          '        \\   |   /         ',
          '      \'  \\  |  /  \'       ',
          '    ~  ~ (     ) ~  ~     ',
          '        _.-"""-._         ',
          '      .\'         \'.       ',
          '     /             \\      ',
          '    |               |     ',
          '     \\             /      ',
          '      \'._       _.\'       ',
          '         \'-...-\'          ',
          '           | |            ',
        ];
      case 'autumn':
        return [
          '      .   ,   .   ,   ',
          '    ,   .   ,    .    ',
          '       _.-"""-._      ',
          '     .\'  ,   .  \'.    ',
          '    /  .    ,     \\   ',
          '   |    ,  .   ,   |  ',
          '    \\  .    ,     /   ',
          '     \'._       _.\'    ',
          '        \'-...-\'       ',
          '          | |         ',
          '       ~~~~~~~~~      ',
        ];
      case 'winter':
        return [
          '      *   *   *   *   ',
          '    *   *   *    *    ',
          '       _.-"""-._      ',
          '     .\' *     * \'.    ',
          '    /   *   *     \\   ',
          '   |  *    *   *   |  ',
          '    \\   *   *     /   ',
          '     \'._       _.\'    ',
          '        \'-...-\'       ',
          '          | |         ',
          '       ^^^^^^^^^      ',
        ];
      default:
        return [];
    }
  }

  String _getSeasonName(String season) {
    switch (season) {
      case 'spring': return 'Spring';
      case 'summer': return 'Summer';
      case 'autumn': return 'Autumn';
      case 'winter': return 'Winter';
      default: return '';
    }
  }

  String _getSeasonMessage(String season) {
    switch (season) {
      case 'spring':
        return 'Cherry blossoms bloom.\nNew beginnings drift on the breeze.\nEvery season leaves a mark — so does every page you write.';
      case 'summer':
        return 'Warm sun, long days.\nThe world stretches out before you.\nSome moments are worth writing down before they fade.';
      case 'autumn':
        return 'Rain taps on golden leaves.\nThe world paints itself anew.\nWhat you notice today becomes tomorrow\'s memory.';
      case 'winter':
        return 'Snow falls silently.\nWarm light glows from within.\nSome thoughts are worth keeping — that is what this is for.';
      default:
        return '';
    }
  }

  Color _seasonColor(NobaroThemeData theme, String season) {
    switch (season) {
      case 'spring': return const Color(0xFFFFB7C5);
      case 'summer': return const Color(0xFFFFD700);
      case 'autumn': return const Color(0xFFFF8C00);
      case 'winter': return Colors.white70;
      default: return theme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nobaro',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"A peaceful offline note engine"',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: theme.tertiary,
              ),
            ),
            const SizedBox(height: 40),
            _buildLogo(),
            const SizedBox(height: 20),
            _buildSeasonArt(theme),
            const SizedBox(height: 20),
            Text(
              _getSeasonName(_season),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSeasonMessage(_season),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                height: 1.5,
                color: theme.onSurface,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () async {
                SoundManager.playSave();
                await SessionState().playerRepo.completeOnboarding();
                AppRouter.onboardingComplete = true;
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRouter.today);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.secondary),
                ),
                child: Text(
                  'BEGIN YOUR STORY',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo.png',
      width: 120,
      height: 120,
    );
  }

  Widget _buildSeasonArt(NobaroThemeData theme) {
    return Text(
      _artLines.join('\n'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 10,
        height: 1.1,
        color: _seasonColor(theme, _season),
      ),
    );
  }
}
