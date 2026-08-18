import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../design/paper.dart';
import '../../core/models/note.dart';
import '../../core/utils/date_utils.dart';
import '../../data/session_state.dart';
import '../../router/app_router.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final SessionState _session = SessionState();
  final TextEditingController _includeController = TextEditingController();
  final TextEditingController _excludeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  DateTime? _fromDate;
  DateTime? _toDate;
  final Set<String> _selectedMoods = {':D', ':)', ':|', ':(', ';('};
  List<Note> _results = [];
  bool _searched = false;

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surfaceContainer,
        title: Text('ADVANCED GREP', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.secondary, fontSize: 14)),
        iconTheme: IconThemeData(color: theme.secondary),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.outline),
        ),
      ),
      body: Row(
        children: [
          // Filters Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: theme.outline))),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildFilterField(theme, 'INCLUDE WORDS', _includeController),
                _buildFilterField(theme, 'EXCLUDE WORDS', _excludeController),
                _buildFilterField(theme, 'TAGS (#daily, etc)', _tagsController),
                const SizedBox(height: 16),
                Text('MOODS', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [':D', ':)', ':|', ':(', ';('].map((m) => FilterChip(
                    label: Text(m, style: const TextStyle(fontSize: 10)),
                    selected: _selectedMoods.contains(m),
                    onSelected: (val) => setState(() => val ? _selectedMoods.add(m) : _selectedMoods.remove(m)),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    backgroundColor: theme.surfaceContainerLow,
                    selectedColor: theme.primary,
                    labelStyle: TextStyle(fontFamily: 'JetBrainsMono', color: _selectedMoods.contains(m) ? theme.onPrimary : theme.onSurface),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text('DATE RANGE', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                const SizedBox(height: 8),
                _dateBtn(theme, 'FROM: ${_fromDate != null ? _fromDate!.toIso8601String().substring(0, 10) : "ANY"}', () async {
                   final d = await _pickDate();
                   if (d != null) setState(() => _fromDate = d);
                }),
                const SizedBox(height: 4),
                _dateBtn(theme, 'TO:   ${_toDate != null ? _toDate!.toIso8601String().substring(0, 10) : "ANY"}', () async {
                   final d = await _pickDate();
                   if (d != null) setState(() => _toDate = d);
                }),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('SEARCH ARCHIVES', style: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Results Area
          Expanded(
            child: _searched 
              ? _results.isEmpty 
                ? Center(child: Text('NO MATCHING MEMORIES FOUND', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurfaceVariant)))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) => _buildResultRow(theme, _results[index]),
                  )
              : Center(child: Text('READY TO SEARCH...', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurfaceVariant))),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(NobaroThemeData theme, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
        TextField(
          controller: controller,
          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.onSurface),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.outline.withValues(alpha: 0.3))),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _dateBtn(NobaroThemeData theme, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: theme.surfaceContainerLow,
        child: Text(text, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurface)),
      ),
    );
  }

  Future<DateTime?> _pickDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
  }

  Future<void> _performSearch() async {
    await _session.unlockEventAchievement('GREP_USED');
    final include = _includeController.text.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();
    final exclude = _excludeController.text.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();
    final tags = _tagsController.text.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();

    final allNotes = await _session.noteRepo.normalNotes();
    setState(() {
      _results = allNotes.where((note) {
        final content = note.content.toLowerCase();
        final noteTags = note.tags.toLowerCase();
        
        // Include words (must have all)
        if (include.isNotEmpty && !include.every((w) => content.contains(w))) return false;
        
        // Exclude words (must have none)
        if (exclude.isNotEmpty && exclude.any((w) => content.contains(w))) return false;
        
        // Tags
        if (tags.isNotEmpty && !tags.every((t) => noteTags.contains(t))) return false;

        // Moods
        if (!_selectedMoods.contains(note.mood)) return false;

        // Date range
        final noteDate = DateTime.parse(note.date);
        if (_fromDate != null && noteDate.isBefore(_fromDate!)) return false;
        if (_toDate != null && noteDate.isAfter(_toDate!)) return false;

        return true;
      }).toList();
      _results.sort((a, b) => b.date.compareTo(a.date));
      _searched = true;
    });
  }

  Widget _buildResultRow(NobaroThemeData theme, Note note) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRouter.editor, arguments: note),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.outline.withValues(alpha: 0.1)))),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(width: 80, child: Text(note.date, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.secondary))),
            Text(note.mood, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(child: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: theme.onSurface))),
          ],
        ),
      ),
    );
  }
}
