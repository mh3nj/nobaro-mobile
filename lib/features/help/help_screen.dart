import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../design/paper.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surfaceContainer,
        title: Text('SYSTEM HELP', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.secondary, fontSize: 14)),
        iconTheme: IconThemeData(color: theme.secondary),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.outline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(theme, 'GETTING STARTED', 
            'Nobaro is your digital soul engine. It is designed to be an offline-only space for your thoughts, memories, and reflections.'),
          const SizedBox(height: 16),
          _buildHelpSection(theme, 'KEYBOARD SHORTCUTS (SIMULATED)', 
            'F1: This Help screen\n'
            'F5: Timeline / History View\n'
            'F8: ASCII Art Gallery\n'
            'F10: Retro Screensaver\n'
            'F12: System Settings'),
          const SizedBox(height: 16),
          _buildHelpSection(theme, 'SPECIAL FEATURES', 
            '- ASCII ART: Insert retro art into any note \u2014 or paste your own and it is saved forever.\n'
            '- SEALING: Lock a note until a future date. It will remain hidden until that day arrives.\n'
            '- TEMPLATES: Use pre-defined structures for daily or weekly logs.\n'
            '- XP & LEVELS: Earn experience points by writing and staying consistent.'),
          const SizedBox(height: 16),
          _buildHelpSection(theme, 'PRIVACY', 
            'Your data never leaves this device. There is no cloud, no tracking, and no ads. You own your soul.'),
          const SizedBox(height: 24),
          Center(
            child: Text('10 PRINT "THANKS FOR USING NOBARO"', 
              style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(NobaroThemeData theme, String title, String content) {
    return Paper(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.secondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface, height: 1.4)),
        ],
      ),
    );
  }
}
