import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/models/custom_art.dart';

/// Persists the user's own ASCII arts to a single JSON file next to the
/// templates file — the same flat-file pattern the desktop app uses for
/// user-created content. Saved arts survive restarts forever.
class AsciiArtRepository {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ascii_arts.json');
  }

  Future<List<CustomArt>> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> json = jsonDecode(content);
      return json
          .map((e) => CustomArt.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<CustomArt> arts) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(arts.map((a) => a.toJson()).toList()));
  }
}
