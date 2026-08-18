import '../models/player.dart';
import '../models/note.dart';
import '../models/achievement.dart';
import 'date_utils.dart';

class PlayerLogic {
  static const List<(int, String)> levels = [
    (0, 'BEGINNER'),
    (50, 'APPRENTICE'),
    (150, 'EXPLORER'),
    (350, 'CHRONICLER'),
    (700, 'HISTORIAN'),
    (1200, 'ARCHIVIST'),
    (2000, 'SAGE'),
    (3000, 'ORACLE'),
    (4500, 'LEGEND'),
    (6500, 'MYTHIC'),
    (99999, 'TRANSCENDENT'),
  ];

  static const int xpNormalNote = 25;
  static const int xpLongNote = 50;
  static const int xpStreakBonus = 10;

  static String getLevelName(int xp) {
    String name = levels.first.$2;
    for (final lvl in levels) {
      if (xp >= lvl.$1) name = lvl.$2;
    }
    return name;
  }

  static int getLevelIndex(int xp) {
    int idx = 0;
    for (int i = 0; i < levels.length; i++) {
      if (xp >= levels[i].$1) idx = i;
    }
    return idx;
  }

  static int xpForNextLevel(int xp) {
    for (final lvl in levels) {
      if (lvl.$1 > xp) return lvl.$1;
    }
    return 99999;
  }

  static int calcNoteXp(String content, {bool hasMedia = false, bool usedFormatting = false}) {
    int xp = xpNormalNote;
    if (content.length >= 500) xp += xpLongNote;
    if (hasMedia) xp += 10;
    if (usedFormatting) xp += 5;
    return xp;
  }

  static List<String> checkAchievements(
    List<Note> notes,
    List<Achievement> achievements,
    Player player,
  ) {
    final newly = <String>[];
    void unlock(String aid) {
      for (final a in achievements) {
        if (a.id == aid && !a.unlocked) {
          a.unlocked = true;
          a.unlockedDate = DateHelper.today();
          newly.add(aid);
        }
      }
    }

    final normalNotes = notes.where((n) => n.noteType == 'normal').toList();
    final n = normalNotes.length;

    if (n >= 1) unlock('FIRST_NOTE');
    if (n >= 10) unlock('NOTES_10');
    if (n >= 100) unlock('NOTES_100');

    if (normalNotes.any((note) => note.content.length >= 500)) {
      unlock('WROTE_LONG');
    }
    if (normalNotes.any((note) => note.media.isNotEmpty)) {
      unlock('MEDIA_STAR');
    }
    final usedMoods = normalNotes.map((n) => n.mood).toSet();
    if (usedMoods.containsAll([':)', ':D', ':|', ':(', ';('])) {
      unlock('ALL_MOODS');
    }

    final noteDicts = normalNotes.map((n) => n.date).toList();
    final streak = DateHelper.calculateStreak(noteDicts);
    player.currentStreak = streak;
    if (streak > player.longestStreak) player.longestStreak = streak;
    if (streak >= 7) unlock('STREAK_7');
    if (streak >= 30) unlock('STREAK_30');

    final hour = DateTime.now().hour;
    if (hour >= 23 || hour < 5) unlock('NIGHT_OWL');

    final last7 = normalNotes.length >= 7 ? normalNotes.sublist(normalNotes.length - 7) : normalNotes;
    if (last7.length == 7) {
      if (last7.every((n) => n.mood == ':)' || n.mood == ':D')) unlock('HAPPY_WEEK');
      if (last7.every((n) => n.mood == ':(' || n.mood == ';(')) unlock('CRYING_WEEK');
    }

    if (normalNotes.any((note) => note.xpEarned > 0)) unlock('RICH_TEXT');

    return newly;
  }

  static int applyStreakBonus(Player player) {
    final streak = player.currentStreak;
    if (streak < 3) return 0;
    final bonus = xpStreakBonus * (streak ~/ 7 + 1);
    player.xp += bonus;
    return bonus;
  }
}
