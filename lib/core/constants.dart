class AppConstants {
  static const String appName = 'Nobaro';
  static const String appVersion = '1';
  static const String appTagline = 'Your Digital Soul';

  static const String dataDir = 'Nobaro';
  static const String notesDir = 'Database';
  static const String mediaDir = 'Media';
  static const String backupsDir = 'Backups';
  static const String exportsDir = 'Exports';

  static const int autoSaveIntervalSeconds = 120;
  static const int maxNoteLength = 50000;
  static const int maxTagsLength = 500;

  static const List<String> themeNames = [
    'Warm Paper',
    'Midnight Ink',
    'Sakura Morning',
    'Coffee Notebook',
    'Winter Ink',
    'Ocean Terminal',
    'Library',
    'Classic DOS',
  ];

  static const List<String> moodSymbols = [':)', ':D', ':|', ':(', ';('];
  static const List<String> moodNames = [
    'Happy', 'Laughing', 'Neutral', 'Sad', 'Crying',
  ];
  static const Map<String, int> moodColors = {
    ':)': 0xFF55FF55,
    ':D': 0xFFFFFF55,
    ':|': 0xFFAAAAAA,
    ':(': 0xFFFF5555,
    ';(': 0xFF5555FF,
  };

  static const List<String> achievementIds = [
    'FIRST_NOTE', 'STREAK_7', 'STREAK_30', 'NOTES_10', 'NOTES_100',
    'CRYING_WEEK', 'HAPPY_WEEK', 'ALL_MOODS', 'BURNED_NOTE',
    'FUTURE_LETTER', 'WROTE_LONG', 'GREP_USED', 'NIGHT_OWL',
    'RICH_TEXT', 'MEDIA_STAR', 'ASCII_ARTIST', 'TEMPLATE_USER',
  ];

  static const Map<String, String> achievementNames = {
    'FIRST_NOTE': '[*] First Note',
    'STREAK_7': '[FIRE] 7-Day Streak',
    'STREAK_30': '[FLAME] 30-Day Streak',
    'NOTES_10': '[10] Ten Notes',
    'NOTES_100': '[100] One Hundred Notes',
    'CRYING_WEEK': '[RAIN] Crying Week',
    'HAPPY_WEEK': '[SUN] Happy Week',
    'ALL_MOODS': '[RAINBOW] All Moods',
    'BURNED_NOTE': '[ASH] Burned Note',
    'FUTURE_LETTER': '[CLOCK] Future Letter',
    'WROTE_LONG': '[SCROLL] Long Note',
    'GREP_USED': '[LENS] Grep Master',
    'NIGHT_OWL': '[OWL] Night Owl',
    'RICH_TEXT': '[PEN] Rich Text Master',
    'MEDIA_STAR': '[STAR] Media Star',
    'ASCII_ARTIST': '[ART] ASCII Artist',
    'TEMPLATE_USER': '[TMPL] Template User',
  };

  static const Map<String, String> achievementDescriptions = {
    'FIRST_NOTE': 'You wrote your first entry!',
    'STREAK_7': 'A whole week of memories!',
    'STREAK_30': 'A month of dedication!',
    'NOTES_10': 'Getting into the habit!',
    'NOTES_100': 'True chronicler!',
    'CRYING_WEEK': 'Seven sad days. You survived.',
    'HAPPY_WEEK': 'Seven days of smiling!',
    'ALL_MOODS': 'You felt everything.',
    'BURNED_NOTE': 'Some memories are ash.',
    'FUTURE_LETTER': 'Wrote to future-you!',
    'WROTE_LONG': '500+ chars in one entry!',
    'GREP_USED': 'Searched your memories.',
    'NIGHT_OWL': 'Writing after midnight!',
    'RICH_TEXT': 'Used formatting!',
    'MEDIA_STAR': 'Attached a file to a note!',
    'ASCII_ARTIST': 'Created ASCII art!',
    'TEMPLATE_USER': 'Applied a template!',
  };

  static const List<String> dailyQuotes = [
    'One note = one memory saved.',
    'Future you will thank present you for this line.',
    "Beep beep! You're doing great.",
    "PRINT 'Hello World' to yourself today.",
    'Every day deserves a line of text.',
    'No internet needed for this feeling.',
    'QBasic taught us: we can create anything.',
    'This note is a gift to future you.',
    'The screen glows because you do.',
    'Your story compiles without errors.',
    'Even GOTO was a step forward.',
    "10 PRINT 'you matter' : 20 GOTO 10",
    'The best diary is the one you actually write.',
    'Yesterday is a note you already saved.',
    'Feelings are just data with feelings.',
    'Write it. Even badly. Especially badly.',
    'Gorillas.bas never judged anyone.',
    'In a world of streams, be a note file.',
  ];
}
