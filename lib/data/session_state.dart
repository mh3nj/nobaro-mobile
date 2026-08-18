import '../core/models/player.dart';
import '../core/models/note.dart';
import '../core/models/achievement.dart';
import '../core/models/template.dart';
import '../core/models/custom_art.dart';
import '../core/utils/player_logic.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/sound_manager.dart';
import 'repositories/note_repository.dart';
import 'repositories/player_repository.dart';
import 'repositories/achievement_repository.dart';
import 'repositories/template_repository.dart';
import 'repositories/ascii_art_repository.dart';

class SessionState {
  static final SessionState _instance = SessionState._();
  factory SessionState() => _instance;
  SessionState._();

  final NoteRepository noteRepo = NoteRepository();
  final PlayerRepository playerRepo = PlayerRepository();
  final AchievementRepository achievRepo = AchievementRepository();
  final TemplateRepository templateRepo = TemplateRepository();
  final AsciiArtRepository asciiArtRepo = AsciiArtRepository();

  Player _player = Player();
  List<Achievement> _achievements = [];
  List<Template> _templates = [];
  List<CustomArt> _customArts = [];
  bool _initialized = false;

  Player get player => _player;
  List<Achievement> get achievements => _achievements;
  List<Template> get templates => _templates;
  List<CustomArt> get customArts => _customArts;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _player = await playerRepo.load();
    _achievements = await achievRepo.load();
    _templates = await templateRepo.load();
    _customArts = await asciiArtRepo.load();
    _initialized = true;
  }

  Future<int> awardXp(int amount, {bool checkLevelUp = true}) async {
    final oldLevel = PlayerLogic.getLevelIndex(_player.xp);
    _player.xp += amount;
    final newLevel = PlayerLogic.getLevelIndex(_player.xp);
    await playerRepo.save(_player);
    if (checkLevelUp && newLevel > oldLevel) return newLevel;
    return -1;
  }

  Future<List<String>> checkNewAchievements() async {
    final notes = await noteRepo.normalNotes();
    final newlyUnlocked = PlayerLogic.checkAchievements(notes, _achievements, _player);
    if (newlyUnlocked.isNotEmpty) {
      await achievRepo.save(_achievements);
      await playerRepo.save(_player);
    }
    return newlyUnlocked;
  }

  /// Called the first (and only the first) time a given note is saved.
  /// Awards note XP, checks for a streak bonus, and folds the note's
  /// word count into the lifetime total — mirroring the desktop app's
  /// `is_new` gate so XP can't be farmed by re-saving/autosaving the
  /// same entry. Returns the new level index if this save leveled the
  /// player up, or -1 otherwise.
  Future<int> onNoteCreated(Note note) async {
    final xp = PlayerLogic.calcNoteXp(
      note.content,
      hasMedia: note.media.isNotEmpty,
      usedFormatting: note.formatting.isNotEmpty,
    );
    note.xpEarned = xp;
    await noteRepo.saveNote(note);
    _player.totalWords += note.wordCount;
    final leveledTo = await awardXp(xp);
    await checkNewAchievements();

    if (_player.currentStreak >= 3) {
      final bonus = PlayerLogic.applyStreakBonus(_player);
      if (bonus > 0) {
        SoundManager.playStreak(_player.currentStreak);
      }
    }

    _player.lastOpen = DateHelper.today();
    await playerRepo.save(_player);
    return leveledTo;
  }

  /// Called when re-saving a note that already exists on disk — editing
  /// an older entry, or an autosave tick on a note already created this
  /// session. No XP or streak bonus here; those are one-time rewards for
  /// bringing a new entry into existence, same as the desktop app.
  Future<void> onNoteUpdated(Note note) async {
    await noteRepo.saveNote(note);
    _player.totalWords += note.wordCount;
    await checkNewAchievements();
    _player.lastOpen = DateHelper.today();
    await playerRepo.save(_player);
  }

  /// Unlocks a one-off, event-triggered achievement (as opposed to the
  /// state-derived ones in PlayerLogic.checkAchievements) and awards its
  /// XP the first time it fires. Safe to call every time the triggering
  /// action happens — it's a no-op once already unlocked.
  Future<void> unlockEventAchievement(String achievementId, {int xp = 0}) async {
    bool changed = false;
    for (final a in _achievements) {
      if (a.id == achievementId && !a.unlocked) {
        a.unlocked = true;
        a.unlockedDate = DateHelper.today();
        changed = true;
      }
    }
    if (xp > 0) await awardXp(xp, checkLevelUp: false);
    if (changed) await achievRepo.save(_achievements);
  }
}
