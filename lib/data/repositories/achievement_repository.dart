import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/models/achievement.dart';
import '../../core/constants.dart';
import '../database/app_paths.dart';

class AchievementRepository {
  final AppPaths _paths = AppPaths();

  Future<List<Achievement>> load() async {
    final base = await _paths.basePath;
    final file = File(p.join(base, 'achievements.json'));
    if (!file.existsSync()) {
      return AppConstants.achievementIds.map((id) => Achievement(id: id)).toList();
    }
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as List<dynamic>;
      final loaded = data.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
      final loadedIds = loaded.map((a) => a.id).toSet();
      for (final id in AppConstants.achievementIds) {
        if (!loadedIds.contains(id)) {
          loaded.add(Achievement(id: id));
        }
      }
      return loaded;
    } catch (_) {
      return AppConstants.achievementIds.map((id) => Achievement(id: id)).toList();
    }
  }

  Future<void> save(List<Achievement> achievements) async {
    final base = await _paths.basePath;
    final file = File(p.join(base, 'achievements.json'));
    await file.writeAsString(jsonEncode(achievements.map((a) => a.toJson()).toList()));
  }
}
