import 'dart:async';
import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../core/models/note.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/word_counter.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/player_logic.dart';
import '../../data/session_state.dart';
import '../../router/app_router.dart';
import '../templates/templates_screen.dart';

import 'package:flutter_tts/flutter_tts.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;

  const EditorScreen({super.key, this.note});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final SessionState _session = SessionState();
  final FlutterTts _tts = FlutterTts();
  late Note _currentNote;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSaving = false;
  bool _isSpeaking = false;
  bool _isNew = true;
  Timer? _autoSaveTimer;
  String? _lastSaved;
  String _oldContent = '';
  final List<String> _moods = [':D', ':)', ':|', ':(', ';('];

  @override
  void initState() {
    super.initState();
    // Seed _currentNote synchronously so the very first build() never
    // touches an uninitialized field — _initNote() below is async and
    // wouldn't resolve before Flutter's first build pass otherwise.
    // The only thing that genuinely needs the async round-trip is
    // confirming _isNew against disk; everything else is known up front.
    _currentNote = widget.note != null
        ? Note.clone(widget.note!)
        : Note(
            id: IdGenerator.generateNoteId(),
            date: DateHelper.today(),
            timeWritten: DateHelper.nowTime(),
            mood: ':)',
          );
    // Conservative default: assume "not new" for a handed-in note until
    // proven otherwise, so a save that lands before the disk check
    // resolves can never double-award XP for an already-existing note.
    _isNew = widget.note == null;
    _oldContent = _currentNote.content;
    _controller = TextEditingController(text: _currentNote.content);
    _focusNode = FocusNode();
    _controller.addListener(_onContentChanged);
    _startAutoSave();
    _focusNode.requestFocus();
    _initNote();
    _initTts();
  }

  void _initTts() {
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      if (_controller.text.isNotEmpty) {
        setState(() => _isSpeaking = true);
        await _tts.speak(_controller.text);
      }
    }
  }

  Future<void> _initNote() async {
    await _session.initialize();
    if (widget.note != null) {
      // A note was handed to us — either an existing entry (opened from
      // the sidebar/timeline) or a not-yet-saved one (e.g. a gap-fill
      // note). Check disk, not just "was an argument passed", so XP is
      // only ever awarded the first time a note is truly created —
      // and a day is never capped at reopening the same entry.
      final existing = await _session.noteRepo.findById(widget.note!.id);
      final isNew = existing == null;
      if (mounted) {
        setState(() => _isNew = isNew);
      } else {
        _isNew = isNew;
      }
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_controller.text.isNotEmpty && _controller.text != _oldContent && !_isSaving) {
        _save(silent: true);
      }
    });
  }

  void _onContentChanged() {
    _currentNote.content = _controller.text;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _controller.removeListener(_onContentChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save({bool silent = false}) async {
    if (_isSaving) return;
    _isSaving = true;
    try {
      // Mirrors the desktop app: an empty brand-new note is never saved
      // (nothing to lose either — the guard just avoids littering the
      // notes folder with blank files from an idle "New Entry" tap).
      if (_isNew && _controller.text.trim().isEmpty) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('(empty note not saved)', style: TextStyle(fontFamily: 'JetBrainsMono')),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      _currentNote.content = _controller.text;
      _currentNote.wordCount = WordCounter.countWords(_controller.text);
      _currentNote.timeWritten = DateHelper.nowTime();

      int leveledTo = -1;
      if (_isNew) {
        leveledTo = await _session.onNoteCreated(_currentNote);
        _isNew = false;
      } else {
        await _session.onNoteUpdated(_currentNote);
      }
      _oldContent = _currentNote.content;

      if (!silent) {
        SoundManager.playSave();
        if (mounted) {
          setState(() => _lastSaved = DateHelper.nowTime());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ ENTRY RECORDED', style: TextStyle(fontFamily: 'JetBrainsMono')),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF00AA00),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          );
        }
      }

      if (leveledTo >= 0 && mounted) {
        SoundManager.playLevelUp();
        await _showLevelUpDialog(leveledTo);
      }
    } finally {
      _isSaving = false;
    }
  }

  Future<void> _showLevelUpDialog(int levelIndex) async {
    if (!mounted) return;
    final theme = NobaroTheme.of(context);
    final levelName = PlayerLogic.getLevelName(_session.player.xp);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('LEVEL UP!', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontWeight: FontWeight.bold)),
        content: Text(
          'You have reached\n$levelName',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurface, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CONTINUE', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _burnNote() async {
    final theme = NobaroTheme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildRetroConfirm(theme, 'BURN THIS MEMORY FOREVER?\nThis cannot be undone.'),
    );
    if (confirm != true) return;
    await _session.noteRepo.deleteNote(_currentNote);
    await _session.unlockEventAchievement('BURNED_NOTE');
    SoundManager.playBurn();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleExit() async {
    final hasUnsaved = _controller.text != _oldContent && _controller.text.trim().isNotEmpty;
    if (hasUnsaved) {
      final theme = NobaroTheme.of(context);
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => _buildRetroConfirm(theme, 'SAVE BEFORE LEAVING?'),
      );
      if (confirm == true) {
        await _save();
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    final wordCount = WordCounter.countWords(_controller.text);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopStatus(theme),
            _buildEditorToolbar(theme),
            Expanded(
              child: Container(
                color: theme.surfaceContainerLowest,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    height: 1.5,
                    color: theme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'Start writing your soul here...',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 14,
                      color: theme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomStatusBar(theme, wordCount),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatus(NobaroThemeData theme) {
    return Container(
      height: 32,
      color: theme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.secondary, size: 16),
            onPressed: _handleExit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            'RECORDING: ${_currentNote.date}',
            style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.primary, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _buildMoodPicker(theme),
        ],
      ),
    );
  }

  Widget _buildMoodPicker(NobaroThemeData theme) {
    return PopupMenuButton<String>(
      initialValue: _currentNote.mood,
      onSelected: (val) => setState(() => _currentNote.mood = val),
      color: theme.surfaceContainer,
      offset: const Offset(0, 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.outline),
          color: theme.surfaceContainerLow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MOOD: ${_currentNote.mood}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.secondary)),
            Icon(Icons.arrow_drop_down, color: theme.secondary, size: 14),
          ],
        ),
      ),
      itemBuilder: (context) => _moods.map((m) => PopupMenuItem(
        value: m,
        child: Text(m, style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurface)),
      )).toList(),
    );
  }

  Widget _buildEditorToolbar(NobaroThemeData theme) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        border: Border(bottom: BorderSide(color: theme.outline)),
      ),
      child: Row(
        children: [
          _toolBtn(theme, 'SAVE', _save),
          if (!_isNew) _toolBtn(theme, 'BURN', _burnNote),
          _toolBtn(theme, 'TMPL', () async {
            final result = await Navigator.of(context).pushNamed(AppRouter.templates);
            if (result != null && result is Map<String, dynamic>) {
              final content = result['content'] as String;
              final tags = result['tags'] as String;
              if (_controller.text.isNotEmpty) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => _buildRetroConfirm(theme, 'REPLACE CONTENT WITH TEMPLATE?'),
                );
                if (confirm != true) return;
              }
              setState(() {
                _controller.text = content;
                _currentNote.tags = tags;
              });
              await _session.unlockEventAchievement('TEMPLATE_USER', xp: 5);
            }
          }),
          _toolBtn(theme, 'ASCII', () async {
            final result = await Navigator.of(context).pushNamed(AppRouter.asciiGallery);
            if (result != null && result is String) {
              final text = _controller.text;
              final selection = _controller.selection;
              final newText = text.replaceRange(selection.start, selection.end, '\n$result\n');
              _controller.value = TextEditingController.fromValue(
                TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: selection.start + result.length + 2),
                ),
              ).value;
              await _session.unlockEventAchievement('ASCII_ARTIST', xp: 15);
            }
          }),
          _toolBtn(theme, 'SEAL', () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: theme.primary,
                    onPrimary: theme.onPrimary,
                    surface: theme.surface,
                    onSurface: theme.onSurface,
                  ),
                ),
                child: child!,
              ),
            );
            if (date != null) {
              final dateStr = date.toIso8601String().substring(0, 10);
              _currentNote.noteType = 'future';
              _currentNote.sealedUntil = dateStr;
              await _save(silent: true);
              await _session.unlockEventAchievement('FUTURE_LETTER', xp: 50);
              SoundManager.playSeal();
              if (mounted) Navigator.of(context).pop();
            }
          }),
          _toolBtn(theme, _isSpeaking ? 'STOP' : 'SPEAK', _speak),
          const Spacer(),
          _toolBtn(theme, 'QUIT', _handleExit),
        ],
      ),
    );
  }

  Widget _buildRetroConfirm(NobaroThemeData theme, String message) {
    return AlertDialog(
      backgroundColor: theme.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text('CONFIRMATION', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontSize: 14)),
      content: Text(message, style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurface, fontSize: 12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('NO', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.tertiary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('YES', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _toolBtn(NobaroThemeData theme, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildBottomStatusBar(NobaroThemeData theme, int wordCount) {
    return Container(
      height: 28,
      color: theme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('WORDS: $wordCount', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.tertiary)),
          const SizedBox(width: 12),
          Text('CHARS: ${_controller.text.length}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.tertiary)),
          const Spacer(),
          if (_lastSaved != null)
            Text('LAST RECORD: $_lastSaved', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: theme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
