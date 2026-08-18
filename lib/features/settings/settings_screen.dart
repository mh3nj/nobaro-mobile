import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../design/paper.dart';
import '../../core/constants.dart';
import '../../core/utils/player_logic.dart';
import '../../data/session_state.dart';
import '../../core/models/achievement.dart';
import '../../design/theme_definitions.dart';
import '../../core/utils/sound_manager.dart';

import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String)? onThemeChanged;

  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SessionState _session = SessionState();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _session.initialize();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(child: Text('LOADING CONFIG...', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary))),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildSectionHeader(theme, 'SYSTEM SETUP'),
                  _buildThemePicker(theme),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, 'PLAYER PROFILE'),
                  _buildPlayerStats(theme),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, 'ACHIEVEMENTS'),
                  _buildAchievementsList(theme),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, 'ABOUT NOBARO'),
                  _buildAboutInfo(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NobaroThemeData theme) {
    return Container(
      height: 32,
      color: theme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('SYSTEM CONFIGURATION UTILITY', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(NobaroThemeData theme, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: theme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.secondary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildThemePicker(NobaroThemeData theme) {
    return Paper(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COLOR SCHEME:', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ThemeDefinitions.all.keys.map((name) {
              final isSelected = theme.name == name;
              return GestureDetector(
                onTap: () {
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(name);
                    SoundManager.playNotify();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primary : theme.surfaceContainerLow,
                    border: Border.all(color: theme.outline),
                  ),
                  child: Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 9,
                      color: isSelected ? theme.onPrimary : theme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(NobaroThemeData theme) {
    final player = _session.player;
    return Paper(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _statsRow('RANK', PlayerLogic.getLevelName(player.xp), theme.primary),
          _statsRow('XP', '${player.xp} units', theme.onSurface),
          _statsRow('WORDS', '${player.totalWords}', theme.onSurface),
          _statsRow('STREAK', '${player.currentStreak} days', theme.secondary),
          _statsRow('RECORD', '${player.longestStreak} days', theme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _statsRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: Colors.grey)),
          Text(value, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(NobaroThemeData theme) {
    final achievements = _session.achievements;
    return Paper(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: achievements.map((a) {
          final name = AppConstants.achievementNames[a.id] ?? a.id;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(a.unlocked ? ' [X] ' : ' [ ] ', 
                  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: a.unlocked ? theme.primary : theme.onSurfaceVariant)),
                Expanded(
                  child: Text(name.toUpperCase(), 
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: a.unlocked ? theme.onSurface : theme.onSurfaceVariant.withValues(alpha: 0.5))),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAboutInfo(NobaroThemeData theme) {
    return Paper(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _linkText('NOBARO OS v${AppConstants.appVersion}', 'https://github.com/mh3nj/nobaro-mobile/', theme.secondary, bold: true),
          const SizedBox(height: 4),
          Text(AppConstants.appTagline, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          _linkText('AUTHOR: MOHSEN JAFARI', 'https://mh3n.com', theme.primary),
          _linkText('SPONSORED BY DAHGAN', 'https://dahgan.com', theme.tertiary),
          _linkText('AND PARSEGAN', 'https://parsegan.com', theme.tertiary),
          const SizedBox(height: 12),
          const Text('AN OFFLINE-ONLY DIGITAL SOUL ENGINE.', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: Colors.grey)),
          const Text('NO CLOUD. NO TRACKING. NO REGRETS.', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _linkText(String text, String url, Color color, {bool bold = false}) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }


  Widget _buildFooter(NobaroThemeData theme) {
    return Container(
      height: 32,
      color: theme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ENTER Select  ESC Back', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurface)),
          IconButton(
            icon: Icon(Icons.close, size: 14, color: theme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
