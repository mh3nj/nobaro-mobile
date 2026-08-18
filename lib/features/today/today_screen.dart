import 'dart:io';
import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../design/paper.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/player_logic.dart';
import '../../core/constants.dart';
import '../../data/session_state.dart';
import '../../router/app_router.dart';
import '../../core/models/note.dart';
import '../../core/utils/id_generator.dart';

import '../../design/mood_graph.dart';
import '../../design/notebook_sheet.dart';
import '../../core/constants/ascii_art.dart';
import '../../core/utils/sound_manager.dart';
import '../letters/sealed_letter_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => TodayScreenState();
}

class TodayScreenState extends State<TodayScreen> {
  final SessionState _session = SessionState();
  bool _loading = true;
  List<Note> _todayNotes = [];
  String? _yesterdayContent;
  int _wordCount = 0;
  String _levelName = 'BEGINNER';
  int _xp = 0;
  int _xpNext = 99999;
  int _streak = 0;
  List<Note> _allNotes = [];
  List<String> _newAchievements = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    SoundManager.playStartup();
  }

  Future<void> _loadData() async {
    await _session.initialize();
    _todayNotes = await _session.noteRepo.findTodayNotes();
    _allNotes = await _session.noteRepo.normalNotes();

    _wordCount = _todayNotes.fold(0, (sum, n) => sum + n.wordCount);

    final yDate = DateHelper.yesterday();
    for (final n in _allNotes) {
      if (n.date == yDate) {
        _yesterdayContent = n.content.length > 200
            ? '${n.content.substring(0, 200)}...'
            : n.content;
        break;
      }
    }

    final allDates = _allNotes.map((n) => n.date).toList();
    _streak = DateHelper.calculateStreak(allDates);
    _levelName = PlayerLogic.getLevelName(_session.player.xp);
    _xp = _session.player.xp;
    _xpNext = PlayerLogic.xpForNextLevel(_session.player.xp);

    if (!_session.initialized || _session.player.lastOpen.isEmpty) {
      await _session.playerRepo.completeOnboarding();
    }

    if (mounted) setState(() => _loading = false);

    _checkSealedLetters();
    _checkGaps();
  }


  Future<void> _checkSealedLetters() async {
    final ready = await _session.noteRepo.findSealedReady();
    if (ready.isNotEmpty && mounted) {
      for (final letter in ready) {
        SoundManager.playLetterOpen();
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SealedLetterScreen(note: letter)),
        );
        letter.noteType = 'normal';
        await _session.noteRepo.saveNote(letter);
      }
      _loadData();
    }
  }

  Future<void> _checkGaps() async {
    final allDates = _allNotes.map((n) => n.date).toList();
    final gaps = DateHelper.getGapDates(allDates);
    if (gaps.isNotEmpty) {
      if (mounted) {
        final fill = await showDialog<bool>(
          context: context,
          builder: (context) => _buildRetroConfirm(NobaroTheme.of(context), 'SYSTEM DETECTED GAPS IN YOUR TIMELINE. WOULD YOU LIKE TO FILL THE EARLIEST ONE (${gaps.first})?'),
        );
        if (fill == true) {
          final gapNote = Note(
            id: IdGenerator.generateNoteId(),
            date: gaps.first,
            timeWritten: '00:00',
          );
          Navigator.of(context).pushNamed(AppRouter.editor, arguments: gapNote).then((_) => _loadData());
        }
      }
    }
  }

  Future<void> _writeUnsentLetter() async {
    final theme = NobaroTheme.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('UNSENT LETTER', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontSize: 14)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurface),
          decoration: InputDecoration(
            hintText: 'Who is this letter to? (optional)',
            hintStyle: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('CANCEL', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.tertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text('WRITE', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (name == null) return;
    final header = name.isNotEmpty ? 'Dear $name,\n\n' : 'To whom it may concern,\n\n';
    final note = Note(
      id: IdGenerator.generateNoteId(),
      date: DateHelper.today(),
      timeWritten: DateHelper.nowTime(),
      content: header,
      tags: '#unsent #letter',
      mood: ':(',
    );
    SoundManager.playSad();
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRouter.editor, arguments: note).then((_) => _loadData());
  }

  Future<void> _showMoodStats() async {
    final theme = NobaroTheme.of(context);
    final moodCounts = <String, int>{};
    for (final n in _allNotes) {
      moodCounts[n.mood] = (moodCounts[n.mood] ?? 0) + 1;
    }
    final totalWords = _allNotes.fold<int>(0, (sum, n) => sum + n.wordCount);

    await showDialog<void>(
      context: context,
      builder: (context) => NotebookSheet(
        title: 'MOOD & STATS',
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: theme.secondary, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LAST 180 DAYS', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: theme.onSurfaceVariant)),
              const SizedBox(height: 6),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: CustomPaint(
                  painter: MoodGraphPainter(notes: _allNotes, theme: theme, days: 180),
                ),
              ),
              const SizedBox(height: 16),
              Text('TOTAL ENTRIES: ${_allNotes.length}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface)),
              const SizedBox(height: 4),
              Text('TOTAL WORDS: $totalWords', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface)),
              const SizedBox(height: 12),
              Text('MOOD BREAKDOWN', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: theme.onSurfaceVariant)),
              const SizedBox(height: 4),
              for (final mood in [':D', ':)', ':|', ':(', ';('])
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('$mood   ${moodCounts[mood] ?? 0}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetroConfirm(NobaroThemeData theme, String message) {
    return AlertDialog(
      backgroundColor: theme.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text('SYSTEM PROMPT', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontSize: 14)),
      content: Text(message, style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurface, fontSize: 12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('IGNORE', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.tertiary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('PROCEED', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(child: Text('LOADING SYSTEM...', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary))),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView(
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 16),
                    _buildStatusStrip(theme),
                    const SizedBox(height: 16),
                    _buildMoodSection(theme),
                    const SizedBox(height: 16),
                    _buildTodayBox(theme),
                    const SizedBox(height: 16),
                    if (_yesterdayContent != null) _buildMemoryBox(theme),
                    const SizedBox(height: 16),
                    _buildQuoteBox(theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomMenu(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(NobaroThemeData theme) {
    return Container(
      height: 32,
      color: theme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _buildMenu(theme, 'FILE', [
            _menuAction('New Entry', () => Navigator.of(context).pushNamed(AppRouter.editor).then((_) => _loadData())),
            _menuAction('Export', () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final path = await _session.noteRepo.exportPlainText();
                final fileName = path.split(Platform.pathSeparator).last;
                messenger.showSnackBar(
                  SnackBar(content: Text('✓ Exported to $fileName', style: const TextStyle(fontFamily: 'JetBrainsMono'))),
                );
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Export failed — check storage permissions.', style: TextStyle(fontFamily: 'JetBrainsMono'))),
                );
              }
            }),
            _menuAction('Unsent Letter', () => _writeUnsentLetter()),
            _menuAction('Quit', () {
              SoundManager.playQuit();
              Future.delayed(const Duration(milliseconds: 800), () {
                if (context.mounted) Navigator.of(context).pop();
              });
            }),
          ]),
          _buildMenu(theme, 'VIEW', [
            _menuAction('Timeline', () => Navigator.of(context).pushNamed(AppRouter.timeline).then((_) => _loadData())),
            _menuAction('Screensaver', () => Navigator.of(context).pushNamed(AppRouter.screensaver)),
            _menuAction('Mood Graph', () => _showMoodStats()),
          ]),
          _buildMenu(theme, 'TOOLS', [
            _menuAction('ASCII Art', () => Navigator.of(context).pushNamed(AppRouter.asciiGallery)),
            _menuAction('Templates', () => Navigator.of(context).pushNamed(AppRouter.templates)),
            _menuAction('Advanced Search', () => Navigator.of(context).pushNamed(AppRouter.advancedSearch)),
            _menuAction('Grep Search', () => Navigator.of(context).pushNamed(AppRouter.timeline)),
          ]),
          _buildMenu(theme, 'HELP', [
            _menuAction('F1 Contents', () => Navigator.of(context).pushNamed(AppRouter.help)),
            _menuAction('About', () => Navigator.of(context).pushNamed(AppRouter.settings)),
          ]),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('NOBARO v${AppConstants.appVersion}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(NobaroThemeData theme, String title, List<PopupMenuEntry<void>> items) {
    return PopupMenuButton<void>(
      offset: const Offset(0, 32),
      color: theme.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(title, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface)),
      ),
      itemBuilder: (context) => items,
    );
  }

  PopupMenuItem<void> _menuAction(String label, VoidCallback onTap) {
    return PopupMenuItem<void>(
      onTap: onTap,
      height: 32,
      child: Text(label, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
    );
  }


  Widget _buildHeader(NobaroThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AsciiArt.logoSmall, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 6, color: theme.primary, height: 1.1)),
        const SizedBox(height: 8),
        Text('10 PRINT "YOU MATTER"', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.secondary)),
        Text('20 GOTO 10', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.secondary)),
      ],
    );
  }

  Widget _buildStatusStrip(NobaroThemeData theme) {
    return Paper(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Text(' LVL: $_levelName ', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('XP: $_xp / $_xpNext', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.tertiary)),
          const Spacer(),
          Text('STREAK: $_streak d', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: _streak >= 3 ? Colors.yellow : theme.tertiary)),
        ],
      ),
    );
  }

  Widget _buildMoodSection(NobaroThemeData theme) {
    return Paper(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MOOD GRAPH (60 DAYS)', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: theme.onSurfaceVariant)),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CustomPaint(
              painter: MoodGraphPainter(notes: _allNotes, theme: theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayBox(NobaroThemeData theme) {
    if (_todayNotes.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRouter.editor).then((_) => _loadData()),
        child: Paper(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('System idle. Press here to start recording your soul...', 
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: theme.onSurfaceVariant)),
          ),
        ),
      );
    }

    return Column(
      children: _todayNotes.map((note) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(AppRouter.editor, arguments: note).then((_) => _loadData()),
          child: Paper(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: theme.primary,
                  child: Row(
                    children: [
                      Text('LOG ENTRY: ${note.timeWritten}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onPrimary, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(note.mood, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onPrimary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    note.content,
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: theme.onSurface, height: 1.4),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }


  Widget _buildMemoryBox(NobaroThemeData theme) {
    return Paper(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('>>> MEMORY FROM YESTERDAY', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.secondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            '"$_yesterdayContent"',
            style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.onSurface, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteBox(NobaroThemeData theme) {
    final idx = DateTime.now().millisecondsSinceEpoch ~/ 86400000 % AppConstants.dailyQuotes.length;
    final quote = AppConstants.dailyQuotes[idx];
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          '"$quote"',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildBottomMenu(NobaroThemeData theme) {
    return Container(
      height: 32,
      color: theme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _menuItem(theme, 'F1 Help', () {
            Navigator.of(context).pushNamed(AppRouter.help);
          }),
          _menuItem(theme, 'F5 Cozy', () {
             Navigator.of(context).pushNamed(AppRouter.timeline).then((_) => _loadData());
          }),
          _menuItem(theme, 'F8 ASCII', () {
            Navigator.of(context).pushNamed(AppRouter.asciiGallery);
          }),
          _menuItem(theme, 'F10 Scr', () {
            Navigator.of(context).pushNamed(AppRouter.screensaver);
          }),
          _menuItem(theme, 'F12 Set', () {
            Navigator.of(context).pushNamed(AppRouter.settings);
          }),
        ],
      ),
    );
  }

  Widget _menuItem(NobaroThemeData theme, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface)),
      ),
    );
  }
}
