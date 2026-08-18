import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../core/models/note.dart';

class SealedLetterScreen extends StatelessWidget {
  final Note note;
  const SealedLetterScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border.all(color: theme.primary, width: 2),
              color: theme.surfaceContainerLow,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✉ LETTER FROM THE PAST', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, color: theme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('WRITTEN: ${note.date}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.secondary)),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  note.content,
                  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: theme.onSurface, height: 1.5),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('CLOSE - CARRY IT FORWARD', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
