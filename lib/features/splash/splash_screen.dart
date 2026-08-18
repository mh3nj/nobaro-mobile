import 'dart:async';
import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../core/utils/sound_manager.dart';
import '../../router/app_router.dart';
import '../../data/session_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _startSequence();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _status = 'Nobaro');
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _status = 'Nobaro\n\nVersion 1');
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _status = 'Nobaro\n\nVersion 1\n\n_');
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _status = 'Nobaro\n\nVersion 1\n\n_\n\nLoading memories...');

    SoundManager.playStartup();

    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 3000));

    await SessionState().initialize();
    final hasSeen = SessionState().player.lastOpen.isNotEmpty;
    AppRouter.onboardingComplete = hasSeen;

    if (mounted) {
      if (hasSeen) {
        Navigator.of(context).pushReplacementNamed(AppRouter.today);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    return Scaffold(
      backgroundColor: theme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(theme),
              const SizedBox(height: 32),
              if (_status.isNotEmpty)
                Text(
                  _status.contains('Loading') ? 'Loading memories...' : '',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: theme.tertiary,
                  ),
                ),
              if (_status.contains('Loading'))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(NobaroThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo.png',
          width: 160,
          height: 160,
        ),
        const SizedBox(height: 12),
        Text(
          'Nobaro',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.secondary,
          ),
        ),
      ],
    );
  }
}
