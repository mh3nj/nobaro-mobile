import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../design/paper.dart';
import '../../core/models/note.dart';
import '../../core/utils/date_utils.dart';
import '../../data/session_state.dart';
import '../../router/app_router.dart';

import '../../core/utils/sound_manager.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final SessionState _session = SessionState();
  List<Note> _notes = [];
  bool _loading = true;
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _session.initialize();
    _notes = await _session.noteRepo.normalNotes();
    _notes.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) setState(() => _loading = false);
  }

  List<Note> get _filteredNotes {
    if (_searchTerm.isEmpty) return _notes;
    final term = _searchTerm.toLowerCase();
    return _notes.where((n) =>
      n.content.toLowerCase().contains(term) ||
      n.tags.toLowerCase().contains(term) ||
      n.date.contains(term)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    final filtered = _filteredNotes;

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(child: Text('ACCESSING ARCHIVES...', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary))),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, filtered.length),
            _buildSearchBar(theme),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(_searchTerm.isEmpty ? 'ARCHIVES EMPTY' : 'NO RESULTS FOUND', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _buildHistoryRow(theme, filtered[index], index),
                    ),
            ),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NobaroThemeData theme, int count) {
    return Container(
      height: 32,
      color: theme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('HISTORY.LOG', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onPrimary, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('FOUND: $count', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onPrimary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(NobaroThemeData theme) {
    return Container(
      height: 36,
      color: theme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('GREP:', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.secondary, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchTerm = val),
              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search memories...',
                hintStyle: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurfaceVariant.withValues(alpha: 0.5)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchTerm.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, size: 14, color: theme.tertiary),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchTerm = '');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(NobaroThemeData theme, Note note, int index) {
    final moodColor = _getMoodColor(note.mood);
    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed(AppRouter.editor, arguments: note);
        _load();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.outline.withValues(alpha: 0.1))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(note.date, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.secondary)),
            ),
            const SizedBox(width: 8),
            Text(note.mood, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: moodColor, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note.content.replaceAll('\n', ' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildFooter(NobaroThemeData theme) {
    return Container(
      height: 32,
      color: theme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('ESC Close', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurface)),
          const Spacer(),
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
