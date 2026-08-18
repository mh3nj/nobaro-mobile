import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/models/note.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/word_counter.dart';
import '../database/app_paths.dart';

class NoteRepository {
  final AppPaths _paths = AppPaths();

  Future<List<Note>> loadAll() async {
    final notesDir = await _paths.notesPath();
    final dir = Directory(notesDir);
    if (!await dir.exists()) return [];

    final notes = <Note>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          notes.add(Note.fromJson(json));
        } catch (_) {}
      }
    }
    notes.sort((a, b) => a.date.compareTo(b.date));
    return notes;
  }

  Future<void> saveNote(Note note) async {
    final notesDir = await _paths.notesPath();
    if (note.id.isEmpty) {
      note.id = IdGenerator.generateNoteId();
    }
    if (note.date.isEmpty) {
      note.date = DateHelper.today();
    }
    note.wordCount = WordCounter.countWords(note.content);
    note.timeWritten = DateHelper.nowTime();
    final file = File(p.join(notesDir, '${note.id}.json'));
    await file.writeAsString(jsonEncode(note.toJson()));
  }

  Future<void> deleteNote(Note note) async {
    final notesDir = await _paths.notesPath();
    final file = File(p.join(notesDir, '${note.id}.json'));
    if (await file.exists()) await file.delete();
  }

  Future<List<Note>> findTodayNotes() async {
    final notes = await loadAll();
    final today = DateHelper.today();
    return notes.where((n) => n.date == today && n.noteType == 'normal').toList();
  }

  Future<Note?> findToday() async {
    final todayNotes = await findTodayNotes();
    return todayNotes.isNotEmpty ? todayNotes.first : null;
  }

  /// Looks up a note by id directly on disk. Used by the editor to tell
  /// whether a note it was handed (e.g. from the sidebar, or a gap-fill
  /// prompt) has actually been saved before, versus one that only exists
  /// in memory so far — that distinction is what gates one-time XP.
  Future<Note?> findById(String id) async {
    final notesDir = await _paths.notesPath();
    final file = File(p.join(notesDir, '$id.json'));
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      return Note.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Note?> findByDate(String date) async {
    final notes = await loadAll();
    for (final n in notes) {
      if (n.date == date) return n;
    }
    return null;
  }

  Future<List<Note>> normalNotes() async {
    final notes = await loadAll();
    return notes.where((n) => n.noteType == 'normal').toList();
  }

  Future<List<Note>> findSealedReady() async {
    final notes = await loadAll();
    final today = DateHelper.today();
    return notes.where((n) => n.noteType == 'future' && n.sealedUntil.compareTo(today) <= 0).toList();
  }

  Future<List<Note>> search(String term) async {
    final notes = await normalNotes();
    final t = term.toLowerCase();
    return notes.where((n) =>
      n.content.toLowerCase().contains(t) ||
      n.tags.toLowerCase().contains(t)
    ).toList();
  }

  /// Writes every normal note, oldest first, into a single plain-text
  /// file under the Exports folder — mirrors the desktop app's plain
  /// text export. Returns the path written to.
  Future<String> exportPlainText() async {
    final normals = await normalNotes();
    normals.sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();
    final today = DateHelper.today();
    final nowTime = DateHelper.nowTime();

    final lines = <String>[];
    lines.add('=' * 64);
    lines.add('  NOBARO v1 — Your Digital Soul');
    lines.add('  Exported: $today at $nowTime');
    lines.add('  Total notes: ${normals.length}');
    lines.add('=' * 64);
    lines.add('');

    for (final note in normals) {
      lines.add('---[ ${note.date} | ${note.mood} ]---');
      if (note.tags.isNotEmpty) lines.add('Tags: ${note.tags}');
      lines.add('');
      lines.add(note.content);
      lines.add('');
      lines.add('-' * 60);
      lines.add('');
    }
    lines.add('[ END — ${normals.length} notes exported ]');

    final exportsDir = await _paths.exportsPath();
    final ts = '${now.year}${_pad(now.month)}${_pad(now.day)}-${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final filePath = p.join(exportsDir, 'nobaro_export_$ts.txt');
    final file = File(filePath);
    await file.writeAsString(lines.join('\n'));
    return filePath;
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> createBackup() async {
    final backupDir = await _paths.backupsPath();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final dest = Directory(p.join(backupDir, 'backup_$ts'));
    await dest.create(recursive: true);

    final notesDir = await _paths.notesPath();
    final srcDir = Directory(notesDir);
    if (await srcDir.exists()) {
      await for (final f in srcDir.list()) {
        if (f is File) {
          await f.copy(p.join(dest.path, p.basename(f.path)));
        }
      }
    }
  }
}
