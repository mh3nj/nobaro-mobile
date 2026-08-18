import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../design/theme_provider.dart';
import '../../design/nobaro_theme.dart';
import '../../core/constants/ascii_art.dart';
import '../../core/models/custom_art.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../data/session_state.dart';

class AsciiGalleryScreen extends StatefulWidget {
  const AsciiGalleryScreen({super.key});

  @override
  State<AsciiGalleryScreen> createState() => _AsciiGalleryScreenState();
}

class _ArtEntry {
  final String name;
  final String content;
  final bool isCustom;
  final String? customId;

  _ArtEntry({
    required this.name,
    required this.content,
    required this.isCustom,
    this.customId,
  });
}

class _AsciiGalleryScreenState extends State<AsciiGalleryScreen> {
  final SessionState _session = SessionState();
  int _selectedIndex = 0;
  bool _loading = true;
  List<_ArtEntry> _entries = [];

  List<_ArtEntry> get _customEntries => _entries.where((e) => e.isCustom).toList();
  List<_ArtEntry> get _builtinEntries => _entries.where((e) => !e.isCustom).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _session.initialize();
    if (!mounted) return;
    setState(() {
      _entries = _buildEntries();
      _loading = false;
      _clampSelection();
    });
  }

  List<_ArtEntry> _buildEntries() {
    return [
      for (final art in _session.customArts)
        _ArtEntry(name: art.name, content: art.content, isCustom: true, customId: art.id),
      for (final piece in AsciiArt.gallery)
        _ArtEntry(name: piece['name']!, content: piece['content']!, isCustom: false),
    ];
  }

  void _clampSelection() {
    if (_entries.isEmpty) {
      _selectedIndex = 0;
    } else if (_selectedIndex >= _entries.length) {
      _selectedIndex = _entries.length - 1;
    }
  }

  void _refreshEntries() {
    _entries = _buildEntries();
    _clampSelection();
  }

  Future<void> _addArt() async {
    final art = await _showArtEditor();
    if (art == null) return;
    _session.customArts.add(art);
    await _session.asciiArtRepo.save(_session.customArts);
    await _session.unlockEventAchievement('ASCII_ARTIST', xp: 15);
    if (!mounted) return;
    setState(() {
      _refreshEntries();
      _selectedIndex = _customEntries.length - 1;
    });
  }

  Future<void> _editArt(String id) async {
    final art = _session.customArts.firstWhere((a) => a.id == id);
    final updated = await _showArtEditor(art: art);
    if (updated == null) return;
    art.name = updated.name;
    art.content = updated.content;
    await _session.asciiArtRepo.save(_session.customArts);
    if (!mounted) return;
    setState(_refreshEntries);
  }

  Future<void> _deleteArt(String id) async {
    final theme = NobaroTheme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('DELETE ART?', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontSize: 14)),
        content: Text(
          'This art will be removed forever.',
          style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.onSurface, fontSize: 12),
        ),
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
      ),
    );
    if (confirm != true) return;
    _session.customArts.removeWhere((a) => a.id == id);
    await _session.asciiArtRepo.save(_session.customArts);
    if (!mounted) return;
    setState(_refreshEntries);
  }

  int _maxLineWidth(String text) {
    var maxW = 0;
    for (final line in text.split('\n')) {
      if (line.length > maxW) maxW = line.length;
    }
    return maxW;
  }

  /// Dialog for creating or editing a custom art. Returns the saved art,
  /// or null if cancelled. Shows a live preview and warns when any line
  /// is wider than the 34-char safe width for small phones.
  Future<CustomArt?> _showArtEditor({CustomArt? art}) async {
    final theme = NobaroTheme.of(context);
    final nameCtrl = TextEditingController(text: art?.name ?? '');
    final contentCtrl = TextEditingController(text: art?.content ?? '');
    final result = await showDialog<CustomArt>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final maxWidth = _maxLineWidth(contentCtrl.text);
          final tooWide = maxWidth > 34;
          final isNew = art == null;
          return AlertDialog(
            backgroundColor: theme.surfaceContainer,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: Text(
              isNew ? 'NEW ASCII ART' : 'EDIT ASCII ART',
              style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.primary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: math.min(460, MediaQuery.of(dialogContext).size.width * 0.92),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NAME', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.onSurface),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'My Art',
                        hintStyle: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.onSurfaceVariant.withValues(alpha: 0.5)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.outline)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PASTE YOUR ART (monospace — keep lines \u2264 34 chars)',
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 10,
                      minLines: 6,
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.onSurface, height: 1.3),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '  .--.\n / o o \\\n(  \\_/  )\n `-...-\'',
                        hintStyle: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: theme.onSurfaceVariant.withValues(alpha: 0.5)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: theme.outline)),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tooWide
                          ? '\u26A0 WIDEST LINE: $maxWidth chars \u2014 over 34, may overflow on small phones'
                          : 'WIDEST LINE: $maxWidth chars (safe \u2264 34)',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        color: tooWide ? const Color(0xFFFFAA00) : theme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('PREVIEW', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Container(
                      height: 150,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.surfaceContainerLowest,
                        border: Border.all(color: theme.outline.withValues(alpha: 0.4)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Text(
                            contentCtrl.text.isEmpty ? '(art preview will appear here)' : contentCtrl.text,
                            style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: theme.primary, height: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(null),
                child: Text('CANCEL', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.tertiary)),
              ),
              ElevatedButton(
                onPressed: contentCtrl.text.trim().isEmpty
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop(CustomArt(
                          id: isNew ? IdGenerator.generateNoteId() : art.id,
                          name: nameCtrl.text.trim().isEmpty ? 'MY ART' : nameCtrl.text.trim(),
                          content: contentCtrl.text
                              .replaceAll('\r\n', '\n')
                              .replaceAll('\r', '\n')
                              .replaceAll(RegExp(r'\n+$'), ''),
                          createdAt: isNew ? DateHelper.today() : art.createdAt,
                        ));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  disabledBackgroundColor: theme.outline,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text('SAVE', style: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
    nameCtrl.dispose();
    contentCtrl.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NobaroTheme.of(context);
    final customEntries = _customEntries;
    final builtinEntries = _builtinEntries;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surfaceContainer,
        title: Text('ASCII GALLERY', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.secondary, fontSize: 14)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: theme.primary,
            tooltip: 'New art',
            onPressed: _loading ? null : _addArt,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.outline),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Sidebar List
                Container(
                  width: 190,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: theme.outline)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionHeader(theme, 'MY ARTS (${customEntries.length})'),
                      if (customEntries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            'None yet \u2014 tap + to add yours',
                            style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: theme.onSurfaceVariant),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: customEntries.length,
                            itemBuilder: (context, index) =>
                                _buildSidebarRow(theme, customEntries[index], index),
                          ),
                        ),
                      _sectionHeader(theme, 'BUILT-IN (${builtinEntries.length})'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: builtinEntries.length,
                          itemBuilder: (context, index) =>
                              _buildSidebarRow(theme, builtinEntries[index], customEntries.length + index),
                        ),
                      ),
                    ],
                  ),
                ),
                // Preview Area
                Expanded(
                  child: Container(
                    color: theme.surfaceContainerLowest,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: Text(
                          _entries.isEmpty ? '' : _entries[_selectedIndex].content,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 10,
                            color: theme.primary,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.surfaceContainer,
          border: Border(top: BorderSide(color: theme.outline)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CLOSE', style: TextStyle(fontFamily: 'JetBrainsMono', color: theme.tertiary)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _entries.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop(_entries[_selectedIndex].content);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('INSERT', style: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(NobaroThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: theme.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSidebarRow(NobaroThemeData theme, _ArtEntry entry, int flatIndex) {
    final selected = _selectedIndex == flatIndex;
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      color: selected ? theme.primary.withValues(alpha: 0.2) : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = flatIndex),
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  color: selected ? theme.primary : theme.onSurface,
                ),
              ),
            ),
          ),
          if (entry.isCustom) ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 14, color: theme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              onPressed: () => _editArt(entry.customId!),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 14, color: theme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              onPressed: () => _deleteArt(entry.customId!),
            ),
          ],
        ],
      ),
    );
  }
}
