import 'package:flutter/material.dart';
import '../core/models/note.dart';
import 'nobaro_theme.dart';

class MoodGraphPainter extends CustomPainter {
  final List<Note> notes;
  final NobaroThemeData theme;
  final int days;

  MoodGraphPainter({
    required this.notes,
    required this.theme,
    this.days = 60,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final slotW = (size.width - 4) / days;
    final now = DateTime.now();
    
    final Map<String, String> moodMap = {
      for (var n in notes) if (n.noteType == 'normal') n.date: n.mood
    };

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateStr = date.toIso8601String().substring(0, 10);
      final mood = moodMap[dateStr];
      
      final x = 2 + i * slotW;
      
      if (mood != null) {
        paint.color = _getMoodColor(mood);
        final heightFactor = _getMoodValue(mood);
        final h = size.height * heightFactor;
        canvas.drawRect(Rect.fromLTWH(x, size.height - h, slotW - 1, h), paint);
      } else {
        paint.color = theme.outline.withValues(alpha: 0.2);
        canvas.drawRect(Rect.fromLTWH(x, size.height - 2, slotW - 1, 2), paint);
      }
    }

    // Today marker
    paint.color = theme.primary;
    canvas.drawLine(Offset(size.width - slotW - 1, 0), Offset(size.width - slotW - 1, size.height), paint..strokeWidth = 1);
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case ':D': return Colors.yellow;
      case ':)': return Colors.greenAccent;
      case ':|': return Colors.cyanAccent;
      case ':(': return Colors.orangeAccent;
      case ';(': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  double _getMoodValue(String mood) {
    switch (mood) {
      case ':D': return 1.0;
      case ':)': return 0.8;
      case ':|': return 0.5;
      case ':(': return 0.3;
      case ';(': return 0.15;
      default: return 0.5;
    }
  }

  @override
  bool shouldRepaint(covariant MoodGraphPainter oldDelegate) => true;
}
