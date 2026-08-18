class Player {
  int xp;
  int level;
  bool hasPassword;
  int passwordHash;
  String theme;
  String defaultFont;
  int defaultFontSize;
  String lastOpen;
  int totalWords;
  int longestStreak;
  int currentStreak;
  int autoSaveSecs;
  bool showDailyQuote;
  bool showLastYear;
  String uiLanguage;
  bool defaultRtl;

  Player({
    this.xp = 0,
    this.level = 0,
    this.hasPassword = false,
    this.passwordHash = 0,
    this.theme = 'Warm Paper',
    this.defaultFont = 'JetBrainsMono',
    this.defaultFontSize = 11,
    this.lastOpen = '',
    this.totalWords = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.autoSaveSecs = 120,
    this.showDailyQuote = true,
    this.showLastYear = true,
    this.uiLanguage = 'en',
    this.defaultRtl = false,
  });

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'level': level,
        'has_password': hasPassword,
        'password_hash': passwordHash,
        'theme': theme,
        'default_font': defaultFont,
        'default_font_size': defaultFontSize,
        'last_open': lastOpen,
        'total_words': totalWords,
        'longest_streak': longestStreak,
        'current_streak': currentStreak,
        'auto_save_secs': autoSaveSecs,
        'show_daily_quote': showDailyQuote,
        'show_last_year': showLastYear,
        'ui_language': uiLanguage,
        'default_rtl': defaultRtl,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        xp: json['xp'] as int? ?? 0,
        level: json['level'] as int? ?? 0,
        hasPassword: json['has_password'] as bool? ?? false,
        passwordHash: json['password_hash'] as int? ?? 0,
        theme: json['theme'] as String? ?? 'Warm Paper',
        defaultFont: json['default_font'] as String? ?? 'JetBrainsMono',
        defaultFontSize: json['default_font_size'] as int? ?? 11,
        lastOpen: json['last_open'] as String? ?? '',
        totalWords: json['total_words'] as int? ?? 0,
        longestStreak: json['longest_streak'] as int? ?? 0,
        currentStreak: json['current_streak'] as int? ?? 0,
        autoSaveSecs: json['auto_save_secs'] as int? ?? 120,
        showDailyQuote: json['show_daily_quote'] as bool? ?? true,
        showLastYear: json['show_last_year'] as bool? ?? true,
        uiLanguage: json['ui_language'] as String? ?? 'en',
        defaultRtl: json['default_rtl'] as bool? ?? false,
      );
}
